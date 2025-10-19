class News {
  final int id;
  final String title;
  final String content;
  final String? thumbnail;
  final DateTime createdAt;

  News({
    required this.id,
    required this.title,
    required this.content,
    this.thumbnail,
    required this.createdAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      thumbnail: json['thumbnail'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
