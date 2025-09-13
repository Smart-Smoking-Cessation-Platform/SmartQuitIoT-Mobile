import 'package:flutter/material.dart';

class RecentNewsCard extends StatelessWidget {
  const RecentNewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent News',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View More',
                  style: TextStyle(
                    color: Color(0xFF00D09E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildNewsCard(
                  imageUrl:
                      'https://via.placeholder.com/80x60/FF6B6B/FFFFFF?text=A23',
                  title: 'How to customize your...',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNewsCard(
                  imageUrl:
                      'https://via.placeholder.com/80x60/4ECDC4/FFFFFF?text=PHONE',
                  title: 'Nothing Phone 2 review: It\'s a bit of a...',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNewsCard(
                  imageUrl:
                      'https://via.placeholder.com/80x60/45B7D1/FFFFFF?text=SCREEN',
                  title: 'Lumen review: a breathalyzer...',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNewsCard(
                  imageUrl:
                      'https://via.placeholder.com/80x60/96CEB4/FFFFFF?text=OPPO',
                  title: 'Oppo A...',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard({required String imageUrl, required String title}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFF3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00D09E).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
