class Post {
  final int id;
  final String title;
  final String description;
  final String? content;
  final String? thumbnail;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final PostAccount account;
  final List<PostMedia>? media;
  final List<PostComment>? comments;
  final int likeCount;
  final bool? isLiked;

  const Post({
    required this.id,
    required this.title,
    required this.description,
    this.content,
    this.thumbnail,
    required this.createdAt,
    this.updatedAt,
    required this.account,
    this.media,
    this.comments,
    required this.likeCount,
    this.isLiked,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String?,
      thumbnail: json['thumbnail'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      account: PostAccount.fromJson(json['account'] as Map<String, dynamic>),
      media: json['media'] != null
          ? (json['media'] as List)
                .map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List)
                .map((e) => PostComment.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      likeCount: json['likeCount'] as int,
      isLiked: json['isLiked'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'thumbnail': thumbnail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'account': account.toJson(),
      'media': media?.map((e) => e.toJson()).toList(),
      'comments': comments?.map((e) => e.toJson()).toList(),
      'likeCount': likeCount,
      'isLiked': isLiked,
    };
  }

  Post copyWith({
    int? id,
    String? title,
    String? description,
    String? content,
    String? thumbnail,
    DateTime? createdAt,
    DateTime? updatedAt,
    PostAccount? account,
    List<PostMedia>? media,
    List<PostComment>? comments,
    int? likeCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      thumbnail: thumbnail ?? this.thumbnail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      account: account ?? this.account,
      media: media ?? this.media,
      comments: comments ?? this.comments,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class PostAccount {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;

  const PostAccount({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
  });

  factory PostAccount.fromJson(Map<String, dynamic> json) {
    return PostAccount(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatarUrl': avatarUrl,
    };
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return username;
  }
}

class PostMedia {
  final int id;
  final String mediaUrl;
  final String mediaType;

  const PostMedia({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json['id'] as int,
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'mediaUrl': mediaUrl, 'mediaType': mediaType};
  }
}

class PostComment {
  final int id;
  final String content;
  final DateTime createdAt;
  final PostAccount account;
  final List<PostMedia>? media;
  final List<PostComment>? replies;

  const PostComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.account,
    this.media,
    this.replies,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      account: PostAccount.fromJson(json['account'] as Map<String, dynamic>),
      media: json['media'] != null
          ? (json['media'] as List)
                .map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      replies: json['replies'] != null
          ? (json['replies'] as List)
                .map((e) => PostComment.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'account': account.toJson(),
      'media': media?.map((e) => e.toJson()).toList(),
      'replies': replies?.map((e) => e.toJson()).toList(),
    };
  }
}

class PostListResponse {
  final bool success;
  final String message;
  final List<Post> data;
  final int code;
  final int timestamp;

  const PostListResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory PostListResponse.fromJson(Map<String, dynamic> json) {
    return PostListResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      code: json['code'] as int,
      timestamp: json['timestamp'] as int,
    );
  }
}

class PostDetailResponse {
  final bool success;
  final String message;
  final Post data;
  final int code;
  final int timestamp;

  const PostDetailResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory PostDetailResponse.fromJson(Map<String, dynamic> json) {
    return PostDetailResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: Post.fromJson(json['data'] as Map<String, dynamic>),
      code: json['code'] as int,
      timestamp: json['timestamp'] as int,
    );
  }
}

class PostLikeResponse {
  final bool success;
  final String message;
  final String data;
  final int code;
  final int timestamp;

  const PostLikeResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.code,
    required this.timestamp,
  });

  factory PostLikeResponse.fromJson(Map<String, dynamic> json) {
    return PostLikeResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as String,
      code: json['code'] as int,
      timestamp: json['timestamp'] as int,
    );
  }
}
