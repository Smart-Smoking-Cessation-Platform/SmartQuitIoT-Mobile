import 'package:SmartQuitIoT/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:SmartQuitIoT/views/screens/posts/post_list_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:SmartQuitIoT/models/post.dart';
import 'package:SmartQuitIoT/viewmodels/post_view_model.dart';
import 'package:SmartQuitIoT/views/screens/posts/post_detail_screen.dart';

import '../../../models/state/post_state.dart';

final postViewModelProvider =
StateNotifierProvider<PostViewModel, PostState>((ref) {
  final repo = ref.read(postRepositoryProvider);
  return PostViewModel(repo)..loadLatestPosts();
});

class CommunityTrendingCard extends ConsumerStatefulWidget {
  const CommunityTrendingCard({super.key});

  @override
  ConsumerState<CommunityTrendingCard> createState() =>
      _CommunityTrendingCardState();
}

class _CommunityTrendingCardState
    extends ConsumerState<CommunityTrendingCard> {
  final PageController _pageController = PageController(viewportFraction: 0.8);

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postViewModelProvider);
    final posts = postState.posts;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'community_trending'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PostListScreen()),
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
          const SizedBox(height: 12),

          // Content
          if (postState.isLoading) ...[_buildLoadingState()],
          if (postState.error != null) ...[
            _buildErrorState(postState.error!)
          ],
          if (!postState.isLoading &&
              postState.error == null &&
              posts.isEmpty) ...[_buildEmptyState()],
          if (!postState.isLoading &&
              postState.error == null &&
              posts.isNotEmpty) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 260,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
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
                            value = (1 - (diff * 0.1)).clamp(0.9, 1.0);
                          }
                          return Transform.scale(scale: value, child: child);
                        },
                        child: _buildPostCard(post),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: posts.length,
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
          ]
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: post.id),
          ),
        );
      },
      child: Container(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
        child: post.thumbnail != null && post.thumbnail!.isNotEmpty
            ? Image.network(
          post.thumbnail!,
          height: 260,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'lib/assets/images/news.jpg',
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          },
        )
            : Image.asset(
          'lib/assets/images/news.jpg',
          height: 260,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
            ),
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
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: post.account.avatarUrl != null &&
                            post.account.avatarUrl!.isNotEmpty
                            ? NetworkImage(post.account.avatarUrl!)
                            : null,
                        child: post.account.avatarUrl == null ||
                            post.account.avatarUrl!.isEmpty
                            ? const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        )
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          post.account.displayName,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTimeAgo(post.createdAt),
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
                      _buildAction(Icons.favorite_border, post.likeCount),
                      const SizedBox(width: 12),
                      // _buildAction(
                      //     Icons.chat_bubble_outline,
                      //     post.comments?.length ?? 0),
                      // const SizedBox(width: 12),
                      // _buildAction(Icons.share_outlined, 0),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
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
        )
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
            ),
            SizedBox(height: 16),
            Text('Loading posts...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SizedBox(
      height: 260,
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('Failed to load posts'),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(postViewModelProvider.notifier).refreshPosts(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No posts available'),
            SizedBox(height: 8),
            Text('Check back later for new posts'),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
