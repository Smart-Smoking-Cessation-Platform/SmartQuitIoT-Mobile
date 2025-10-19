import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/models/post.dart';

import '../../../models/post_comment.dart';
import '../../../models/post_media.dart';

class CommentCard extends StatelessWidget {
  final PostComment comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment Header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    comment.account.avatarUrl != null &&
                        comment.account.avatarUrl!.isNotEmpty
                    ? NetworkImage(comment.account.avatarUrl!)
                    : null,
                child:
                    comment.account.avatarUrl == null ||
                        comment.account.avatarUrl!.isEmpty
                    ? const Icon(Icons.person, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.account.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatTimeAgo(comment.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Comment Content
          Text(
            comment.content,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),

          // Comment Media
          if (comment.media != null && comment.media!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildCommentMedia(comment.media!),
          ],

          // Replies
          if (comment.replies != null && comment.replies!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildReplies(comment.replies!),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentMedia(List<PostMedia> media) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        itemBuilder: (context, index) {
          final mediaItem = media[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                mediaItem.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReplies(List<PostComment> replies) {
    return Column(
      children: replies
          .map(
            (reply) => Container(
              margin: const EdgeInsets.only(left: 20, top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reply Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage:
                            reply.account.avatarUrl != null &&
                                reply.account.avatarUrl!.isNotEmpty
                            ? NetworkImage(reply.account.avatarUrl!)
                            : null,
                        child:
                            reply.account.avatarUrl == null ||
                                reply.account.avatarUrl!.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reply.account.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatTimeAgo(reply.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Reply Content
                  Text(
                    reply.content,
                    style: const TextStyle(fontSize: 13, height: 1.3),
                  ),

                  // Reply Media
                  if (reply.media != null && reply.media!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildCommentMedia(reply.media!),
                  ],
                ],
              ),
            ),
          )
          .toList(),
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
