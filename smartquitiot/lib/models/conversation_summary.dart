// lib/models/conversation_summary.dart
// Model cho item trong Inbox (GET /conversations)

class ConversationSummary {
  final int id;
  final String? title; // nullable: group có title, direct có thể null -> we auto-fill if possible
  final String? lastMessage; // nội dung message cuối
  final DateTime? lastUpdatedAt; // thời điểm update cuối (used for sort/display)
  final String? avatarUrl; // avatar của bên kia (optional)
  final int unreadCount;

  ConversationSummary({
    required this.id,
    this.title,
    this.lastMessage,
    this.lastUpdatedAt,
    this.avatarUrl,
    this.unreadCount = 0,
  });

  /// Robust parsing: backend có thể trả timestamp (millis) hoặc ISO string,
  /// lastMessage có thể là string hoặc object { content, sentAt }
  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    // helpers
    int parseInt(dynamic v, [int fallback = 0]) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is String) {
        return int.tryParse(v) ?? fallback;
      }
      if (v is double) return v.toInt();
      return fallback;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is int) {
        try {
          return DateTime.fromMillisecondsSinceEpoch(v);
        } catch (_) {
          return null;
        }
      }
      if (v is String) {
        final asInt = int.tryParse(v);
        if (asInt != null) {
          return DateTime.fromMillisecondsSinceEpoch(asInt);
        }
        try {
          return DateTime.parse(v);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    String? extractLastMessage(Map<String, dynamic> j) {
      final lm = j['lastMessage'];
      if (lm == null) {
        final alt = j['lastMessageContent'] ?? j['last_message'] ?? j['last_message_content'];
        if (alt is String) return alt;
        return null;
      }
      if (lm is String) return lm;
      if (lm is Map) {
        final content = lm['content'] ?? lm['text'] ?? lm['body'];
        if (content is String) return content;
      }
      return null;
    }

    // Try to pick the "counterparty" participant name (useful for DIRECT conv)
    String? extractCounterpartyName(Map<String, dynamic> j) {
      final participants = j['participants'] ?? j['participant'] ?? j['members'] ?? j['participantsList'];
      try {
        if (participants is List && participants.isNotEmpty) {
          // common case: 2 participants (you + other). Pick the last as "other" (best-effort).
          if (participants.length >= 2) {
            final cand = participants.last;
            if (cand is Map) {
              final n = cand['fullName'] ?? cand['name'] ?? cand['displayName'] ?? cand['full_name'];
              if (n is String && n.trim().isNotEmpty) return n.trim();
            }
          }
          // fallback: scan for any participant with a name field
          for (final p in participants) {
            if (p is Map) {
              final n = p['fullName'] ?? p['name'] ?? p['displayName'] ?? p['full_name'];
              if (n is String && n.trim().isNotEmpty) return n.trim();
            }
          }
        } else if (participants is Map) {
          final n = participants['fullName'] ?? participants['name'] ?? participants['displayName'];
          if (n is String && n.trim().isNotEmpty) return n.trim();
        }
      } catch (_) {}
      return null;
    }

    // Pick avatar corresponding to counterparty if possible, else try top-level avatars
    String? extractCounterpartyAvatar(Map<String, dynamic> j) {
      final top = j['avatarUrl'] ?? j['avatar'] ?? j['image'] ?? j['avatar_url'];
      if (top is String && top.trim().isNotEmpty) {
        // don't return yet because maybe participant-based avatar is more accurate
      }

      final participants = j['participants'] ?? j['participant'] ?? j['members'] ?? j['participantsList'];
      try {
        if (participants is List && participants.isNotEmpty) {
          if (participants.length >= 2) {
            final cand = participants.last;
            if (cand is Map) {
              final a = cand['avatarUrl'] ?? cand['avatar'] ?? cand['image'] ?? cand['avatar_url'];
              if (a is String && a.trim().isNotEmpty) return a.trim();
            }
          }
          // fallback: first participant with avatar
          for (final p in participants) {
            if (p is Map) {
              final a = p['avatarUrl'] ?? p['avatar'] ?? p['image'] ?? p['avatar_url'];
              if (a is String && a.trim().isNotEmpty) return a.trim();
            }
          }
        } else if (participants is Map) {
          final a = participants['avatarUrl'] ?? participants['avatar'] ?? participants['image'];
          if (a is String && a.trim().isNotEmpty) return a.trim();
        }
      } catch (_) {}
      // final fallback: top-level
      if (top is String && top.trim().isNotEmpty) return top.trim();
      return null;
    }

    final rawId = json['id'] ?? json['conversationId'] ?? json['conversation_id'] ?? json['convId'];
    final id = parseInt(rawId, 0);

    String? title = (json['title'] ?? json['name'] ?? json['conversationTitle'])?.toString();
    final lastMessage = extractLastMessage(json);

    final dynamic lm = json['lastMessage'];
    final lastUpdatedAt = parseDate(
      json['lastUpdatedAt'] ??
          json['last_updated_at'] ??
          json['updatedAt'] ??
          (lm is Map ? lm['sentAt'] : null),
    );

    // If title null -> try to extract counterparty's fullName
    if ((title == null || title.trim().isEmpty)) {
      final cp = extractCounterpartyName(json);
      if (cp != null && cp.isNotEmpty) {
        title = cp;
      }
    }

    final avatarUrl = extractCounterpartyAvatar(json);

    final unreadRaw = json['unreadCount'] ?? json['unread_count'] ?? json['unread'];
    final unreadCount = parseInt(unreadRaw, 0);

    return ConversationSummary(
      id: id,
      title: title,
      lastMessage: lastMessage,
      lastUpdatedAt: lastUpdatedAt,
      avatarUrl: avatarUrl,
      unreadCount: unreadCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (title != null) 'title': title,
    if (lastMessage != null) 'lastMessage': lastMessage,
    if (lastUpdatedAt != null) 'lastUpdatedAt': lastUpdatedAt!.toIso8601String(),
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    'unreadCount': unreadCount,
  };

  @override
  String toString() {
    return 'ConversationSummary(id: $id, title: $title, lastMessage: $lastMessage, lastUpdatedAt: $lastUpdatedAt, unreadCount: $unreadCount)';
  }
}
