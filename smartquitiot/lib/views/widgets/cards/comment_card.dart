import 'package:flutter/material.dart';
import '../../../models/post_comment.dart';
import '../../../models/post_media.dart';
import '../../../utils/date_formatter.dart';
import '../dialogs/media_viewer_dialog.dart';

class CommentCard extends StatelessWidget {
  final PostComment comment;
  final Function(int)? onReply;
  final Function(int)? onEdit;
  final Function(int)? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    this.onReply,
    this.onEdit,
    this.onDelete,
  });

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
                      DateFormatter.formatPostDate(comment.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Action buttons
              PopupMenuButton<String>(
                onSelected: (value) {
                  print(
                    '🎯 [CommentCard] Menu item selected: $value for comment ID: ${comment.id}',
                  );
                  switch (value) {
                    case 'reply':
                      print(
                        '💬 [CommentCard] Reply action triggered for comment: ${comment.id}',
                      );
                      onReply?.call(comment.id);
                      break;
                    case 'edit':
                      print(
                        '✏️ [CommentCard] Edit action triggered for comment: ${comment.id}',
                      );
                      onEdit?.call(comment.id);
                      break;
                    case 'delete':
                      print(
                        '🗑️ [CommentCard] Delete action triggered for comment: ${comment.id}',
                      );
                      onDelete?.call(comment.id);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'reply',
                    child: Row(
                      children: [
                        Icon(Icons.reply, size: 16),
                        SizedBox(width: 8),
                        Text('Reply'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
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
            CommentMediaList(media: comment.media!),
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
                              DateFormatter.formatPostDate(reply.createdAt),
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
                    CommentMediaList(media: reply.media!),
                  ],
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Separate widget for comment media list to ensure proper context for navigation
class CommentMediaList extends StatelessWidget {
  final List<PostMedia> media;

  const CommentMediaList({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        itemBuilder: (context, index) {
          final mediaItem = media[index];
          final isVideo = mediaItem.mediaType == 'VIDEO';

          return GestureDetector(
            onTap: () {
              print('🖼️ [CommentMediaList] Tapped on media item $index');
              print('🔗 [CommentMediaList] Media URL: ${mediaItem.mediaUrl}');
              print('📹 [CommentMediaList] Is Video: $isVideo');

              // Open full screen viewer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MediaViewerDialog(mediaList: media, initialIndex: index),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      mediaItem.mediaUrl,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
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
                  // Video play icon overlay
                  if (isVideo)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
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
}
