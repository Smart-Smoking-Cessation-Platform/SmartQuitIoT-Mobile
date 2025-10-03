import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:SmartQuitIoT/views/screens/articles/article_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class News {
  final String titleKey; // key cho title
  final String imageUrl;
  final String categoryKey; // key cho category

  const News({
    required this.titleKey,
    required this.imageUrl,
    required this.categoryKey,
  });
}

class RecentNewsCard extends StatefulWidget {
  final List<News> newsList;

  const RecentNewsCard({
    super.key,
    this.newsList = const [
      News(
        titleKey: "title_news1",
        imageUrl: 'lib/assets/images/news.jpg',
        categoryKey: 'category_tech',
      ),
      News(
        titleKey: "title_news2",
        imageUrl: 'lib/assets/images/news.jpg',
        categoryKey: 'category_review',
      ),
      News(
        titleKey: "title_news3",
        imageUrl: 'lib/assets/images/news.jpg',
        categoryKey: 'category_health',
      ),
      News(
        titleKey: "title_news4",
        imageUrl: 'lib/assets/images/news.jpg',
        categoryKey: 'category_gadget',
      ),
    ],
  });

  @override
  State<RecentNewsCard> createState() => _RecentNewsCardState();
}

class _RecentNewsCardState extends State<RecentNewsCard> {
  final PageController _pageController = PageController(viewportFraction: 0.75);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'recent_news'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ArticleListPage(),
                    ),
                  );
                },
                child: Text(
                  'view_more'.tr(),
                  style: const TextStyle(
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(news.imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.25),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
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
                news.categoryKey.tr(),
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
              news.titleKey.tr(),
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
