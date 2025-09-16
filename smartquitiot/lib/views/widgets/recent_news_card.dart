import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class News {
  final String title;
  final String imageUrl;
  final String category;

  const News({
    required this.title,
    required this.imageUrl,
    required this.category,
  });
}

class RecentNewsCard extends StatefulWidget {
  final List<News> newsList;

  const RecentNewsCard({
    super.key,
    this.newsList = const [
      News(
        title: "How to customize your device settings for efficiency",
        imageUrl: 'lib/assets/news.jpg',
        category: 'Tech',
      ),
      News(
        title: "Nothing Phone 2 review: It’s a bit of a mixed bag",
        imageUrl: 'lib/assets/news.jpg',
        category: 'Review',
      ),
      News(
        title: "Lumen review: a breathalyzer for your health",
        imageUrl: 'lib/assets/news.jpg',
        category: 'Health',
      ),
      News(
        title: "Oppo A Series: Top budget phones in 2025",
        imageUrl: 'lib/assets/news.jpg',
        category: 'Gadget',
      ),
    ],
  });

  @override
  State<RecentNewsCard> createState() => _RecentNewsCardState();
}

class _RecentNewsCardState extends State<RecentNewsCard> {
  final PageController _pageController = PageController(viewportFraction: 0.8);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
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

          /// PageView
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.newsList.length,
              itemBuilder: (context, index) {
                final news = widget.newsList[index];

                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.hasClients &&
                        _pageController.position.haveDimensions) {
                      final page =
                          _pageController.page ??
                          _pageController.initialPage.toDouble();
                      double diff = (page - index).abs();
                      value = (1 - (diff * 0.1)).clamp(0.9, 1.0).toDouble();
                    }

                    return Transform.scale(scale: value, child: child);
                  },
                  child: _buildNewsCard(news),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          /// SmoothPageIndicator
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.newsList.length,
              effect: ExpandingDotsEffect(
                activeDotColor: const Color(0xFF00D09E),
                dotColor: Colors.grey.shade300,
                dotHeight: 8,
                dotWidth: 8,
                spacing: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(News news) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(news.imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Gradient overlay để tiêu đề nổi bật
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          /// Category tag
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                news.category,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          /// Title
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Text(
              news.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
