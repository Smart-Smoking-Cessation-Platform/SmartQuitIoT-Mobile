// lib/services/stomp_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:stomp_dart_client/src/stomp_config.dart';
import 'package:stomp_dart_client/src/stomp_frame.dart';

/// Simple robust STOMP wrapper for Flutter (mobile).
/// - Singleton: StompService.instance
/// - Init with wsUrl + optional async tokenProvider
/// - subscribeConversation(convId, callback)
/// - unsubscribeConversation(convId, [callback]) -> if callback null removes all callbacks
/// - sendAppMessage(payload)
/// - isConnected, disconnect()
///
/// Notes:
/// - This uses raw WebSocket (no SockJS). Make sure server does NOT require SockJS.
/// - Token provider should return access token string (without "Bearer " prefix or with — service normalizes).
/// - We attempt auto-resubscribe after reconnect.
/// - Basic dedupe by message id to reduce duplicates on reconnects or accidental double-publishes.
class StompService {
  StompService._internal();

  static final StompService instance = StompService._internal();

  StompClient? _client;
  String? _wsUrl;
  Future<String?> Function()? _tokenProvider;
  bool _autoActivate = true;

  // destination -> list of callbacks
  final Map<String, List<void Function(Map<String, dynamic>)>> _callbacks =
  {};

  // destinations we've already requested subscribe for (to avoid double subscribe)
  final Set<String> _subscribedDestinations = {};

  // small dedupe store: dest -> set of recent ids
  final Map<String, Set<String>> _recentIds = {};
  final int _recentIdsMax = 300; // per dest; prune when exceed

  // simple connection state stream for UI to listen if needed
  final StreamController<bool> _connectedController =
  StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectedController.stream;

  /// Initialize (call once, e.g. app start or when entering chat area)
  Future<void> init({
    required String wsUrl,
    Future<String?> Function()? tokenProvider,
    bool activateImmediately = true,
  }) async {
    // if same config and already active -> just return
    if (_client != null && _wsUrl == wsUrl && _tokenProvider == tokenProvider) {
      return;
    }

    // tear down previous client (if any)
    await disconnect();

    _wsUrl = wsUrl;
    _tokenProvider = tokenProvider;
    _autoActivate = activateImmediately;

    if (_autoActivate) {
      await _connect();
    }
  }

  Future<void> _connect() async {
    if (_wsUrl == null) {
      throw Exception('StompService: wsUrl not set. Call init() first.');
    }

    // get token (if provider supplied)
    String? token;
    try {
      token = _tokenProvider != null ? await _tokenProvider!() : null;
    } catch (e) {
      token = null;
    }

    final Map<String, String> stompHeaders = {};
    if (token != null && token.isNotEmpty) {
      // normalize: allow provider to return "Bearer xyz" or just "xyz"
      if (token.toLowerCase().startsWith('bearer ')) {
        stompHeaders['Authorization'] = token;
      } else {
        stompHeaders['Authorization'] = 'Bearer $token';
      }
    }

    // create stomp client config
    final config = StompConfig(
      url: _wsUrl!,
      // beforeConnect: helpful to wait a bit or refresh token if needed
      beforeConnect: () async {
        // small delay to avoid race on hot reload
        await Future.delayed(const Duration(milliseconds: 200));
        // attempt to refresh token by calling provider once more (optional)
        if (_tokenProvider != null) {
          try {
            final maybe = await _tokenProvider!();
            if (maybe != null && maybe.isNotEmpty) {
              // update headers for initial CONNECT
              if (maybe.toLowerCase().startsWith('bearer ')) {
                stompHeaders['Authorization'] = maybe;
              } else {
                stompHeaders['Authorization'] = 'Bearer $maybe';
              }
            }
          } catch (_) {}
        }
      },
      onConnect: _onConnect,
      onStompError: (StompFrame frame) {
        // server-level error
        print('[StompService] STOMP Error: ${frame.body}');
      },
      onWebSocketError: (dynamic error) {
        print('[StompService] WebSocket error: $error');
      },
      onDisconnect: (frame) {
        print('[StompService] disconnected (stomp onDisconnect)');
        _connectedController.add(false);
      },
      // initial headers for STOMP CONNECT
      stompConnectHeaders: stompHeaders,
      // also pass WS-level headers; some server setups expect auth at WS handshake level
      webSocketConnectHeaders: stompHeaders,
      // heartbeats (Duration)
      heartbeatOutgoing: const Duration(milliseconds: 4000),
      heartbeatIncoming: const Duration(milliseconds: 4000),
      // set reconnect delay so client will try reconnect automatically (Duration)
      reconnectDelay: const Duration(seconds: 5),
      // NOTE: no `debug:` named param here for this package version — use onWebSocketError/onStompError or print in callbacks
    );

    _client = StompClient(config: config);

    try {
      _client!.activate();
    } catch (e) {
      print('[StompService] activate error: $e');
    }
  }

  void _onConnect(StompFrame frame) {
    print('[StompService] connected (server=${frame.headers?['server']})');
    _connectedController.add(true);

    // on connect -> (re)subscribe to previously requested destinations
    // update stompConnectHeaders if tokenProvider has fresh token
    _maybeRefreshHeaders();

    // perform subscribe for each destination that we intended
    for (final dest in _subscribedDestinations) {
      _doSubscribe(dest);
    }
  }

  Future<void> _maybeRefreshHeaders() async {
    if (_tokenProvider == null) return;
    try {
      final t = await _tokenProvider!();
      if (t == null) return;
      String normalized = t;
      if (!normalized.toLowerCase().startsWith('bearer ')) {
        normalized = 'Bearer $normalized';
      }
      final current = _client?.config?.stompConnectHeaders?['Authorization'];
      if (current != normalized) {
        _client?.config?.stompConnectHeaders?['Authorization'] = normalized;
        _client?.config?.webSocketConnectHeaders?['Authorization'] = normalized;
        // NOTE: stomp_dart_client doesn't expose updating CONNECT headers for an already connected session,
        // but on next reconnect it will use config headers. Good enough for token rotation.
      }
    } catch (e) {
      // ignore
    }
  }

  /// Subscribe to conversation topic `/topic/conversations/{convId}`.
  /// Callback gets parsed Map<String,dynamic> (body JSON).
  /// Multiple callbacks per conv allowed (they will all be invoked).
  void subscribeConversation(
      String convId, void Function(Map<String, dynamic>) callback) {
    final dest = '/topic/conversations/$convId';
    final list = _callbacks.putIfAbsent(dest, () => []);
    list.add(callback);

    // mark intended subscription
    _subscribedDestinations.add(dest);

    // subscribe immediately if connected
    if (_client != null && _client!.connected) {
      _doSubscribe(dest);
    }
  }

  /// Unsubscribe: if callback == null -> remove all callbacks for convId.
  /// If callback provided -> remove that single callback.
  /// Note: we don't force-unsubscribe at server-level (stomp_dart_client may not expose unsubscribe id reliably).
  /// We avoid calling client's subscribe again for same dest once all callbacks removed.
  void unsubscribeConversation(String convId,
      [void Function(Map<String, dynamic>)? callback]) {
    final dest = '/topic/conversations/$convId';
    if (!_callbacks.containsKey(dest)) return;
    if (callback == null) {
      _callbacks.remove(dest);
    } else {
      _callbacks[dest]!.remove(callback);
      if (_callbacks[dest]!.isEmpty) _callbacks.remove(dest);
    }

    // if no callbacks left, mark as not subscribed (so on reconnect we won't resubscribe)
    if (!_callbacks.containsKey(dest)) {
      _subscribedDestinations.remove(dest);
      _recentIds.remove(dest);
      // try to call client.unsubscribe if API available (best-effort)
    }
  }

  // internal subscribe wrapper
  void _doSubscribe(String dest) {
    if (_client == null) return;
    if (!_subscribedDestinations.contains(dest)) return;
    if (_subscribedDestinations.contains(dest) && _callbacks[dest] == null) return;

    // avoid double subscribe for same destination
    if (_recentIds.containsKey(dest) && _recentIds[dest]!.contains('__subscribed_marker__')) {
      // already subscribed marker exists
      return;
    }

    try {
      _client!.subscribe(
        destination: dest,
        callback: (StompFrame frame) {
          try {
            final payloadStr = frame.body ?? '';
            if (payloadStr.isEmpty) return;
            final Map<String, dynamic> parsed = jsonDecode(payloadStr);

            // normalize id (server may send id/messageId/clientMessageId)
            final rawId = parsed['id'] ??
                parsed['messageId'] ??
                parsed['clientMessageId'] ??
                parsed['msgId'] ??
                parsed['message_id'] ??
                null;
            final idStr = rawId == null ? null : rawId.toString();

            // dedupe
            if (idStr != null) {
              final ids = _recentIds.putIfAbsent(dest, () => <String>{});
              if (ids.contains(idStr)) {
                // duplicate → skip
                return;
              }
              ids.add(idStr);
              // keep set size bounded
              if (ids.length > _recentIdsMax) {
                // naive prune: keep first half
                final toKeep = ids.take(_recentIdsMax ~/ 2).toSet();
                _recentIds[dest] = toKeep;
              }
            }

            // dispatch to callbacks (if any)
            final cbs = _callbacks[dest];
            if (cbs != null && cbs.isNotEmpty) {
              for (final cb in List.of(cbs)) {
                try {
                  cb(parsed);
                } catch (e) {
                  // swallow per-callback errors
                }
              }
            }
          } catch (e) {
            print('[StompService] _doSubscribe callback parse error: $e');
          }
        },
      );

      // mark subscribed (we use recentIds set as a simple marker store too)
      final markerSet = _recentIds.putIfAbsent(dest, () => <String>{});
      markerSet.add('__subscribed_marker__');
    } catch (e) {
      print('[StompService] subscribe error for $dest: $e');
    }
  }

  /// Send application message to backend (example dest: /app/conversations/messages)
  void sendAppMessage(Map<String, dynamic> payload) {
    if (_client == null || !_client!.connected) {
      print('[StompService] sendAppMessage: not connected');
      return;
    }
    try {
      final body = jsonEncode(payload);
      _client!.send(destination: '/app/conversations/messages', body: body);
    } catch (e) {
      print('[StompService] sendAppMessage error: $e');
    }
  }

  /// Disconnect and cleanup. Safe to call multiple times.
  Future<void> disconnect() async {
    try {
      _connectedController.add(false);
      if (_client != null) {
        try {
          _client!.deactivate();
        } catch (_) {}
        _client = null;
      }
    } catch (e) {
      // ignore
    } finally {
      _subscribedDestinations.clear();
      _callbacks.clear();
      _recentIds.clear();
    }
  }

  bool get isConnected => _client?.connected ?? false;

  /// Useful for debugging
  @override
  String toString() {
    return 'StompService(wsUrl=$_wsUrl, connected=${isConnected}, subs=${_subscribedDestinations.length})';
  }
}
