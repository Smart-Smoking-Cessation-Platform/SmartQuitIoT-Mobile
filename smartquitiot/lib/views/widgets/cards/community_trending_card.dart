import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../screens/community_screen.dart';

class CommunityPost {
  final String authorName;
  final String authorAvatar;
  final String timeAgo;
  final String title;
  final String imageUrl;
  final int likes;
  final int comments;
  final int shares;

  const CommunityPost({
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
    required this.title,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
  });
}

class CommunityTrendingCard extends StatefulWidget {
  final List<CommunityPost> posts;

  const CommunityTrendingCard({
    super.key,
    this.posts = const [
      CommunityPost(
        authorName: 'Alice Smith',
        authorAvatar: 'https://picsum.photos/100',
        timeAgo: '2h ago',
        title: '5 Tips to Quit Smoking in 2025',
        imageUrl: 'lib/assets/news.jpg',
        likes: 120,
        comments: 34,
        shares: 12,
      ),
      CommunityPost(
        authorName: 'John Doe',
        authorAvatar: 'https://picsum.photos/101',
        timeAgo: '5h ago',
        title: 'Healthy Morning Routine to Boost Energy',
        imageUrl: 'lib/assets/news.jpg',
        likes: 89,
        comments: 21,
        shares: 5,
      ),
      CommunityPost(
        authorName: 'Emma Johnson',
        authorAvatar: 'https://picsum.photos/102',
        timeAgo: '1d ago',
        title: 'Meditation Techniques for Busy People',
        imageUrl: 'lib/assets/news.jpg',
        likes: 200,
        comments: 50,
        shares: 30,
      ),
    ],
  });

  @override
  State<CommunityTrendingCard> createState() => _CommunityTrendingCardState();
}

class _CommunityTrendingCardState extends State<CommunityTrendingCard> {
  final PageController _pageController = PageController(viewportFraction: 0.8);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
          // ====== Header ======
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Community - Trending',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CommunityPage()),
                  );
                },
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
          const SizedBox(height: 12),

          // ====== PageView ======
          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.posts.length,
              itemBuilder: (context, index) {
                final post = widget.posts[index];
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
                  child: _buildPostCard(post),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ====== SmoothPageIndicator ======
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.posts.length,
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

  Widget _buildPostCard(CommunityPost post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              post.imageUrl,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient overlay
          Container(
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Post content
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(post.authorAvatar),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        post.authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      post.timeAgo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildAction(Icons.favorite_border, post.likes),
                    const SizedBox(width: 12),
                    _buildAction(Icons.chat_bubble_outline, post.comments),
                    const SizedBox(width: 12),
                    _buildAction(Icons.share_outlined, post.shares),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      ],
    );
  }
}
