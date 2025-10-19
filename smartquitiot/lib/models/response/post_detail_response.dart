import '../post.dart';

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
