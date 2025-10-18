class News {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final List<NewsMedia>? media;

  const News({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.media,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: json['media'] != null
          ? (json['media'] as List)
                .map((e) => NewsMedia.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'media': media?.map((e) => e.toJson()).toList(),
    };
  }

  News copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    List<NewsMedia>? media,
  }) {
    return News(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      media: media ?? this.media,
    );
  }
}

class NewsMedia {
  final int id;
  final String mediaUrl;

  const NewsMedia({required this.id, required this.mediaUrl});

  factory NewsMedia.fromJson(Map<String, dynamic> json) {
    return NewsMedia(
      id: json['id'] as int,
      mediaUrl: json['mediaUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'mediaUrl': mediaUrl};
  }
}

class NewsListResponse {
  final bool success;
  final String message;
  final List<News> data;
  final int code;
  final int timestamp;

  const NewsListResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory NewsListResponse.fromJson(Map<String, dynamic> json) {
    return NewsListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((e) => News.fromJson(e as Map<String, dynamic>))
          .toList(),
      code: json['code'] as int,
      timestamp: json['timestamp'] as int,
    );
  }
}

class NewsDetailResponse {
  final bool success;
  final String message;
  final News data;
  final int code;
  final int timestamp;

  const NewsDetailResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory NewsDetailResponse.fromJson(Map<String, dynamic> json) {
    return NewsDetailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: News.fromJson(json['data'] as Map<String, dynamic>),
      code: json['code'] as int,
      timestamp: json['timestamp'] as int,
    );
  }
}
