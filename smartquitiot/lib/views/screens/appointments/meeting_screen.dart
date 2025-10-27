// lib/views/screens/appointments/meeting_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../services/appointment_service.dart';
import '../../../services/token_storage_service.dart';

class MeetingScreen extends StatefulWidget {
  final int appointmentId;
  final String title;

  const MeetingScreen({Key? key, required this.appointmentId, this.title = ''}) : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final AppointmentService _meetingService = AppointmentService();
  final TokenStorageService _tokenStorage = TokenStorageService();
  final String _agoraAppId = dotenv.env['AGORA_APPID'] ?? '';

  int _localUid = 0;
  String _channel = '';
  String _token = '';
  bool _joined = false;
  int? _remoteUid;
  RtcEngine? _engine;
  Timer? _expiryTimer;

  @override
  void initState() {
    super.initState();
    _initAndJoin();
  }

  Future<void> _initAndJoin() async {
    try {
      if (_agoraAppId.isEmpty) {
        throw Exception('AGORA_APPID is not set (FE env). Please configure AGORA_APPID.');
      }

      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Not logged in.');
      }

      final data = await _meetingService.requestJoinToken(widget.appointmentId, accessToken);
      if (data == null || !data.containsKey('channel') || !data.containsKey('token') || !data.containsKey('uid')) {
        throw Exception('Invalid join token response from server.');
      }

      _channel = data['channel'] as String;
      _token = (data['token'] as String?) ?? '';
      _localUid = (data['uid'] as num).toInt();

      // If your backend requires token, refuse to join when empty token:
      if (_token.isEmpty) {
        // For dev only you may allow empty token; otherwise: show error
        debugPrint('[Meeting] Warning: server returned empty token. Aborting join.');
        _showError('Cannot join meeting: missing token.');
        return;
      }

      // create & initialize engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(appId: _agoraAppId));

      // register callbacks
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            debugPrint('[Agora] join success');
            setState(() { _joined = true; });
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint('[Agora] remote joined: $remoteUid');
            setState(() { _remoteUid = remoteUid; });
          },
          onUserOffline: (connection, remoteUid, reason) {
            debugPrint('[Agora] remote offline: $remoteUid');
            setState(() { if (_remoteUid == remoteUid) _remoteUid = null; });
          },
          onLeaveChannel: (connection, stats) {
            debugPrint('[Agora] left channel');
            setState(() { _joined = false; _remoteUid = null; });
          },

          // <<--- IMPORTANT: accept two args here (connection, token)
          onTokenPrivilegeWillExpire: (connection, token) {
            debugPrint('[Agora] token will expire soon: $token');
            // optional: call backend to refresh token if you implemented refresh
          },
        ),
      );


      await _engine!.enableVideo();
      await _engine!.startPreview();

      // join channel — Agora SDK expects a non-null String token argument.
      await _engine!.joinChannel(
        token: _token, // token must be non-null String (we validated above)
        channelId: _channel,
        uid: _localUid,
        options: const ChannelMediaOptions(),
      );

      // schedule auto-leave on token expiry if server returned expiresAt:
      if (data.containsKey('expiresAt')) {
        final expiresAt = (data['expiresAt'] as num).toInt();
        final nowSec = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
        final remain = expiresAt - nowSec;
        if (remain > 0) {
          _expiryTimer?.cancel();
          _expiryTimer = Timer(Duration(seconds: remain), () {
            _leaveChannel();
            _showExpiredDialog();
          });
        }
      }
    } catch (e, st) {
      debugPrint('Meeting init error: $e\n$st');
      _showError('Cannot join meeting: $e');
    }
  }

  Future<void> _leaveChannel() async {
    try {
      final engine = _engine;
      if (engine != null) {
        await engine.leaveChannel();
        await engine.stopPreview();
        await engine.release();
      }
    } catch (e) {
      debugPrint('Error leaving: $e');
    } finally {
      _expiryTimer?.cancel();
      setState(() {
        _joined = false;
        _engine = null;
        _remoteUid = null;
      });
      // pop only if this screen is on top:
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  void _showExpiredDialog() {
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Session ended'),
      content: const Text('This meeting session expired.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }

  void _showError(String msg) {
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Error'),
      content: Text(msg),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ));
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    // ensure engine cleaned up
    if (_engine != null) {
      _leaveChannel();
    }
    super.dispose();
  }

  Widget _renderLocalPreview() {
    if (!_joined || _engine == null) {
      return const Center(child: Text('Joining...'));
    }
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _renderRemoteView() {
    if (_remoteUid == null) {
      return const Center(child: Text('Waiting for remote...'));
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(channelId: _channel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title.isNotEmpty ? widget.title : 'Meeting - ${_channel.isNotEmpty ? _channel : widget.appointmentId}';
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: const Color(0xFF00D09E)),
      backgroundColor: const Color(0xFFF1FFF3),
      body: Column(
        children: [
          Expanded(
            child: _joined
                ? Row(
              children: [
                Expanded(child: _renderRemoteView()),
                const SizedBox(width: 8),
                SizedBox(width: 150, height: 200, child: _renderLocalPreview()),
              ],
            )
                : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text('Joining ${_channel} ...'),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D09E)),
                onPressed: _leaveChannel,
                child: const Text('Leave'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
