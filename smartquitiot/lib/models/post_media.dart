class PostMedia {
  final int? id;
  final String mediaUrl;
  final String mediaType;

  const PostMedia({
    this.id,
    required this.mediaUrl,
    required this.mediaType,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json['id'] as int?,
      mediaUrl: json['mediaUrl'] as String,
      mediaType: json['mediaType'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'mediaUrl': mediaUrl, 'mediaType': mediaType};
  }
}