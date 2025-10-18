import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:SmartQuitIoT/views/screens/news/news_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:SmartQuitIoT/models/news.dart';
import 'package:SmartQuitIoT/providers/news_provider.dart';
import 'package:SmartQuitIoT/views/screens/news/news_detail_screen.dart';

class RecentNewsCard extends ConsumerStatefulWidget {
  const RecentNewsCard({super.key});

  @override
  ConsumerState<RecentNewsCard> createState() => _RecentNewsCardState();
}

class _RecentNewsCardState extends ConsumerState<RecentNewsCard> {
  final PageController _pageController = PageController(viewportFraction: 0.75);

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(latestNewsProvider);

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
                      builder: (context) => const NewsListScreen(),
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

          /// Content
          newsAsync.when(
            data: (news) {
              if (news.isEmpty) {
                return _buildEmptyState();
              }

              return Column(
                children: [
                  /// PageView
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final newsItem = news[index];

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
                              value = (1 - (diff * 0.1))
                                  .clamp(0.9, 1.0)
                                  .toDouble();
                            }

                            return Transform.scale(scale: value, child: child);
                          },
                          child: _buildNewsCard(newsItem),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// SmoothPageIndicator
                  Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: news.length,
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
              );
            },
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(News news) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsId: news.id),
          ),
        );
      },
      child: Container(
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
        ),
        child: Stack(
          children: [
            // News Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: news.media != null && news.media!.isNotEmpty
                  ? Image.network(
                      news.media!.first.mediaUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.article,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
            ),

            // Gradient overlay
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),

            // News content
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimeAgo(news.createdAt),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading news...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load news',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(latestNewsProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No news available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new articles',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
