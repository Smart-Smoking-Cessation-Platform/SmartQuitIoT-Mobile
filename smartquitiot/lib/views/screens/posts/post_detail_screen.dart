import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/post.dart';
import 'package:SmartQuitIoT/providers/post_provider.dart';
import 'package:SmartQuitIoT/views/widgets/cards/comment_card.dart';
import '../../../models/post_media.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postViewModelProvider.notifier).loadPostDetail(widget.postId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postViewModelProvider);
    final post = postState.selectedPost;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E), // Màu xanh lá cây
        elevation: 0,
        centerTitle: true, // canh giữa tiêu đề
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // icon trắng
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post Detail',
          style: TextStyle(
            color: Colors.white, // chữ trắng
            fontWeight: FontWeight.w600,
            fontSize: 16, // chữ nhỏ gọn
          ),
        ),
      ),

      body: postState.isLoadingDetail
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
              ),
            )
          : postState.error != null
          ? _buildErrorState(postState.error!)
          : post == null
          ? _buildEmptyState()
          : Stack(
              children: [_buildPostContent(post), _buildCommentInputBar(post)],
            ),
    );
  }

  Widget _buildPostContent(Post post) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(post),
          _buildPostBody(post),
          // _buildPostActions(post),
          _buildCommentsSection(post),
        ],
      ),
    );
  }

  Widget _buildPostHeader(Post post) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                post.account.avatarUrl != null &&
                    post.account.avatarUrl!.isNotEmpty
                ? NetworkImage(post.account.avatarUrl!)
                : null,
            child:
                post.account.avatarUrl == null ||
                    post.account.avatarUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.account.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatTimeAgo(post.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(post);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Nội dung bài viết + ảnh/video
  Widget _buildPostBody(Post post) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.content != null && post.content!.isNotEmpty)
            Text(
              post.content!,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          if (post.media != null && post.media!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInlineMedia(post.media!),
          ],
        ],
      ),
    );
  }

  /// Hiển thị ảnh/video xen giữa nội dung
  Widget _buildInlineMedia(List<PostMedia> media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: media.map((item) {
        if (item.mediaType == 'IMAGE') {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.mediaUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          );
        } else if (item.mediaType == 'VIDEO') {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }).toList(),
    );
  }

  // Widget _buildPostActions(Post post) {
  //   final isLiked = ref.watch(postViewModelProvider).isPostLiked(post.id);

  //   return Container(
  //     color: Colors.white,
  //     margin: const EdgeInsets.only(top: 8),
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     child: Row(
  //       children: [
  //         GestureDetector(
  //           onTap: () async {
  //             final viewModel = ref.read(postViewModelProvider.notifier);
  //             final isCurrentlyLiked = ref
  //                 .read(postViewModelProvider)
  //                 .isPostLiked(post.id);

  //             await viewModel.toggleLike(post.id);

  //             if (mounted) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text(
  //                     isCurrentlyLiked
  //                         ? 'You unliked this post 💔'
  //                         : 'You liked this post ❤️',
  //                   ),
  //                   duration: const Duration(seconds: 1),
  //                   behavior: SnackBarBehavior.floating,
  //                 ),
  //               );
  //             }
  //           },
  //           child: Row(
  //             children: [
  //               Icon(
  //                 isLiked ? Icons.favorite : Icons.favorite_border,
  //                 color: isLiked ? Colors.red : Colors.grey[600],
  //                 size: 24,
  //               ),
  //               const SizedBox(width: 8),
  //               Text(
  //                 '${post.likeCount}',
  //                 style: TextStyle(color: Colors.grey[600]),
  //               ),
  //             ],
  //           ),
  //         ),

  //         const SizedBox(width: 24),
  //         Row(
  //           children: [
  //             Icon(
  //               Icons.chat_bubble_outline,
  //               color: Colors.grey[600],
  //               size: 24,
  //             ),
  //             const SizedBox(width: 8),
  //             Text(
  //               '${post.comments?.length ?? 0}',
  //               style: TextStyle(color: Colors.grey[600]),
  //             ),
  //           ],
  //         ),
  //         const Spacer(),
  //         Icon(Icons.share_outlined, color: Colors.grey[600], size: 24),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCommentsSection(Post post) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Comments (${post.comments?.length ?? 0})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          if (post.comments == null || post.comments!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No comments yet. Be the first to comment!',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: post.comments!.length,
              itemBuilder: (_, index) {
                final comment = post.comments![index];
                return CommentCard(comment: comment);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInputBar(Post post) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF00D09E)),
                onPressed: () {
                  final text = _commentController.text.trim();
                  if (text.isNotEmpty) {
                    FocusScope.of(context).unfocus();
                    _commentController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comment sent!')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Post',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(postViewModelProvider.notifier).deletePost(post.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Widget _buildErrorState(String error) => Center(
    child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
  );

  Widget _buildEmptyState() => const Center(
    child: Text('Post not found', style: TextStyle(color: Colors.grey)),
  );
}
