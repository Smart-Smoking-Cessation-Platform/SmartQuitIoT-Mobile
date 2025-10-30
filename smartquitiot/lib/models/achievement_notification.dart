class AchievementNotification {
  final int id;
  final String type;
  final String title;
  final String content;
  final String? icon;
  final String? url;
  final String? deepLink;
  final bool isRead;
  final DateTime createdAt;

  AchievementNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.icon,
    this.url,
    this.deepLink,
    required this.isRead,
    required this.createdAt,
  });

  factory AchievementNotification.fromJson(Map<String, dynamic> json) {
    return AchievementNotification(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      icon: json['icon'] as String?,
      url: json['url'] as String?,
      deepLink: json['deepLink'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'content': content,
      'icon': icon,
      'url': url,
      'deepLink': deepLink,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Extract achievement ID from deep link
  int? get achievementId {
    if (deepLink == null) return null;
    // Format: smartquit://achievement/{id}
    final uri = Uri.tryParse(deepLink!);
    if (uri == null || uri.pathSegments.isEmpty) return null;
    return int.tryParse(uri.pathSegments.last);
  }

  AchievementNotification copyWith({
    int? id,
    String? type,
    String? title,
    String? content,
    String? icon,
    String? url,
    String? deepLink,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AchievementNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      url: url ?? this.url,
      deepLink: deepLink ?? this.deepLink,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
