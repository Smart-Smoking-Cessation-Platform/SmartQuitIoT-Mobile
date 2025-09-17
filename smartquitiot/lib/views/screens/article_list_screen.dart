import 'package:flutter/material.dart';
import 'article_detail_screen.dart'; // import file ArticleDetailPage của bạn

class ArticleListPage extends StatelessWidget {
  const ArticleListPage({super.key});

  // Fake data ví dụ
  final List<Map<String, String>> articles = const [
    {
      'title': 'Mental Wellness in the Digital Age',
      'subtitle': 'The impact of social media and technology on mental health',
      'author': 'Dr. Harrison Lector',
      'image': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
    },
    {
      'title': 'Mindful Eating Practices',
      'subtitle': 'How mindful eating can improve your health',
      'author': 'Dr. Jane Doe',
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836',
    },
    // {
    //   'title': 'Exercise and Mental Health',
    //   'subtitle': 'The connection between physical activity and well-being',
    //   'author': 'Dr. John Smith',
    //   'image': './lib/assets/Achievement.png',
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white), // ⬅️ mũi tên trắng
        title: const Text(
          'Articles',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArticleDetailPage()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      article['image']!,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          article['title']!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle
                        Text(
                          article['subtitle']!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Author + Stats
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[600],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                article['author']!,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            _buildStatItem(Icons.favorite, '331', Colors.red),
                            const SizedBox(width: 12),
                            _buildStatItem(Icons.bookmark, '23K', Colors.black),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(count, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
      ],
    );
  }
}
