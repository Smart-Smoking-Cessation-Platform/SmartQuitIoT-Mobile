import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../repositories/conversation_repository.dart';
import '../../../services/token_storage_service.dart';
import 'chat_bubble.dart';
import 'message_input.dart';

/// Simple local Message model for UI
class Message {
  final String text;
  final bool isUser;
  final String time;
  final String? avatar;

  Message({
    required this.text,
    required this.isUser,
    required this.time,
    this.avatar,
  });
}

/// Chat screen detail: loads history if conversationId provided,
/// or will create conversation on first send using coachAccountId (targetUserId).
class ChatScreenDetail extends StatefulWidget {
  final String coachName;
  final String coachAvatar;
  final int? conversationId; // optional: existing conversation id
  final int? coachAccountId; // optional: target account id to create conversation

  const ChatScreenDetail({
    super.key,
    required this.coachName,
    required this.coachAvatar,
    this.conversationId,
    this.coachAccountId,
  });

  @override
  State<ChatScreenDetail> createState() => _ChatScreenDetailState();
}

class _ChatScreenDetailState extends State<ChatScreenDetail> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ConversationRepository _convRepo = ConversationRepository();
  final TokenStorageService _tokenService = TokenStorageService();

  List<Message> messages = [];
  bool _loadingHistory = false;
  int? _currentAccountId; // parsed from JWT if possible
  int? _conversationIdLocal; // may get updated after first send

  @override
  void initState() {
    super.initState();
    _conversationIdLocal = widget.conversationId;
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    // try parse accountId from JWT (best effort)
    try {
      final token = await _tokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final acct = _parseAccountIdFromJwt(token);
        if (acct != null) _currentAccountId = acct;
      }
    } catch (e) {
      debugPrint('Failed to parse accountId from token: $e');
    }

    // If we already got a conversationId (from inbox), load messages
    if (_conversationIdLocal != null) {
      await _loadMessages(_conversationIdLocal!);
      return;
    }

    // Otherwise, attempt to find existing conversation with coachAccountId
    if (widget.coachAccountId != null) {
      try {
        final found = await _convRepo.findConversationWithTarget(widget.coachAccountId!);
        if (found != null) {
          _conversationIdLocal = found;
          await _loadMessages(found);
          return;
        } else {
          // no existing conversation — keep empty UI (user can send to create)
          setState(() {
            messages = [];
          });
        }
      } catch (e) {
        debugPrint('Error while finding conversation: $e');
        setState(() {
          messages = [];
        });
      }
    } else {
      // no target info — empty UI
      setState(() {
        messages = [];
      });
    }
  }

  int? _parseAccountIdFromJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return null;
      String payload = parts[1];
      // base64Url decode with padding
      String normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> obj = jsonDecode(decoded);
      // common claim names: accountId, sub, idS
      if (obj.containsKey('accountId')) return int.tryParse(obj['accountId'].toString());
      if (obj.containsKey('memberId')) return int.tryParse(obj['memberId'].toString());
      if (obj.containsKey('sub')) return int.tryParse(obj['sub'].toString());
      if (obj.containsKey('id')) return int.tryParse(obj['id'].toString());
    } catch (e) {
      // ignore
    }
    return null;
  }

  Future<void> _loadMessages(int conversationId) async {
    setState(() => _loadingHistory = true);
    try {
      // fetch and cast to dynamic list
      final raw = List<dynamic>.from(await _convRepo.fetchMessages(conversationId: conversationId, limit: 200));

      if (raw.isEmpty) {
        setState(() {
          messages = [];
        });
        return;
      }

      DateTime? tryParse(String? s) {
        if (s == null) return null;
        // try ISO
        try {
          return DateTime.parse(s).toLocal();
        } catch (_) {}
        // try epoch millis (string/number)
        final v = int.tryParse(s);
        if (v != null) return DateTime.fromMillisecondsSinceEpoch(v).toLocal();
        return null;
      }

      DateTime? firstT;
      DateTime? lastT;
      try {
        final dynamic f = raw.first;
        final dynamic l = raw.last;
        final String? fSent = (f?.sentAt ?? (f is Map ? f['sentAt'] : null))?.toString();
        final String? lSent = (l?.sentAt ?? (l is Map ? l['sentAt'] : null))?.toString();
        firstT = tryParse(fSent);
        lastT = tryParse(lSent);
      } catch (_) {
        firstT = null;
        lastT = null;
      }

      List<Message> mapped = raw.map<Message>((m) {
        String? sentAt;
        int? senderId;
        String? senderAvatar;

        try {
          sentAt = (m?.sentAt)?.toString();
        } catch (_) {
          sentAt = null;
        }
        if ((sentAt == null || sentAt.isEmpty) && (m is Map)) {
          sentAt = (m['sentAt'] ?? m['sent_at'] ?? m['createdAt'])?.toString();
        }

        try {
          senderId = (m?.senderId);
          if (senderId is! int && senderId != null) {
            senderId = int.tryParse(senderId.toString());
          }
        } catch (_) {
          senderId = null;
        }
        if (senderId == null && m is Map) {
          final rawSid = (m['senderId'] ?? m['sender_id'] ?? m['accountId']);
          senderId = rawSid is int ? rawSid : int.tryParse(rawSid?.toString() ?? '');
        }

        try {
          senderAvatar = (m?.senderAvatar)?.toString();
        } catch (_) {
          senderAvatar = null;
        }
        if ((senderAvatar == null || senderAvatar.isEmpty) && m is Map) {
          senderAvatar = (m['senderAvatar'] ?? m['senderAvatarUrl'] ?? m['avatarUrl'] ?? m['avatar'])?.toString();
        }

        final content = (() {
          try {
            final c = m?.content;
            if (c != null) return c.toString();
          } catch (_) {}
          if (m is Map) {
            return (m['content'] ?? m['text'] ?? '').toString();
          }
          return '';
        })();

        final isUser = (senderId != null && _currentAccountId != null && senderId == _currentAccountId);
        final timeStr = _formatTimeString(sentAt);

        return Message(text: content, isUser: isUser, time: timeStr, avatar: senderAvatar);
      }).toList();

      if (firstT != null && lastT != null && firstT.isAfter(lastT)) {
        mapped = mapped.reversed.toList();
      }

      setState(() {
        messages = mapped;
      });

      // wait frame then scroll to bottom
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      debugPrint('Failed to load messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không load được lịch sử: $e')));
      }
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  String _formatTimeString(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('HH:mm').format(dt.toLocal());
    } catch (_) {
      final asInt = int.tryParse(raw);
      if (asInt != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(asInt);
        return DateFormat('HH:mm').format(dt.toLocal());
      }
    }
    return raw;
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (_) {
      // fallback
      try {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } catch (_) {}
    }
  }

  Future<void> _sendMessageToServer(String text) async {
    if (text.trim().isEmpty) return;

    // optimistic UI
    final now = TimeOfDay.now();
    final local = Message(
      text: text,
      isUser: true,
      time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    );
    setState(() => messages.add(local));
    _scrollToBottom();

    try {
      final sentDto = await _convRepo.sendMessage(
        conversationId: _conversationIdLocal,
        targetUserId: _conversationIdLocal == null ? widget.coachAccountId : null,
        content: text,
      );

      // CASE A: we didn't have conversationId before, server just created it
      if (_conversationIdLocal == null && sentDto.conversationId != null) {
        _conversationIdLocal = sentDto.conversationId;
        debugPrint('Got new conversationId=${_conversationIdLocal}');

        // Load full history from server (this replaces optimistic message with server canonical data)
        await _loadMessages(_conversationIdLocal!);
        return;
      }

      // CASE B: we already had conversationId -> refresh latest messages from server
      if (_conversationIdLocal != null) {
        await _loadMessages(_conversationIdLocal!);
        return;
      }

      // CASE C: no conversation id and server didn't return one (rare)
      final timeStr = _formatTimeString(sentDto.sentAt);
      if (mounted) {
        setState(() {
          if (messages.isNotEmpty && messages.last.isUser && messages.last.text == text) {
            messages.removeLast();
          }
          messages.add(Message(
            text: sentDto.content,
            isUser: (sentDto.senderId != null && _currentAccountId != null && sentDto.senderId == _currentAccountId),
            time: timeStr,
            avatar: sentDto.senderAvatar,
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Failed to send: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gửi thất bại: $e')));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarIsNotEmpty = widget.coachAvatar.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        centerTitle: true,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(radius: 16, backgroundImage: avatarIsNotEmpty ? NetworkImage(widget.coachAvatar) : null),
          const SizedBox(width: 8),
          Text(widget.coachName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ChatBubble(message: msg);
              },
            ),
          ),
          MessageInput(
            onSend: (text) async {
              await _sendMessageToServer(text);
            },
          ),
        ],
      ),
    );
  }
}
