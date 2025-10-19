import 'news.dart';

enum MediaType { IMAGE, VIDEO }

class NewsMedia {
  final int id;
  final String mediaUrl;
  final MediaType mediaType;

  NewsMedia({
    required this.id,
    required this.mediaUrl,
    required this.mediaType,
  });

  factory NewsMedia.fromJson(Map<String, dynamic> json) {
    return NewsMedia(
      id: json['id'],
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'] == 'VIDEO'
          ? MediaType.VIDEO
          : MediaType.IMAGE,
    );
  }
}

class NewsDetail extends News {
  final String content;
  final List<NewsMedia> media;

  NewsDetail({
    required int id,
    required String title,
    String? thumbnail,
    required DateTime createdAt,
    required this.content,
    required this.media,
  }) : super(
         id: id,
         title: title,
         thumbnail: thumbnail,
         createdAt: createdAt,
         content: content,
       );

  factory NewsDetail.fromJson(Map<String, dynamic> json) {
    return NewsDetail(
      id: json['id'],
      title: json['title'],
      thumbnail: json['thumbnail'],
      createdAt: DateTime.parse(json['createdAt']),
      content: json['content'],
      media: (json['media'] as List).map((e) => NewsMedia.fromJson(e)).toList(),
    );
  }
}
