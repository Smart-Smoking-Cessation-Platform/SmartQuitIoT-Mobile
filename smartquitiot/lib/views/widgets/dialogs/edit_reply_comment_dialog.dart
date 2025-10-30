import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:SmartQuitIoT/models/post_comment.dart';
import 'package:SmartQuitIoT/models/post_media.dart';
import 'package:SmartQuitIoT/providers/post_provider.dart';
import 'package:SmartQuitIoT/services/cloudinary_service.dart';
import 'package:another_flushbar/flushbar.dart';

/// Dialog for editing or replying to comments
class EditReplyCommentDialog extends ConsumerStatefulWidget {
  final int postId;
  final PostComment? comment; // If provided, this is an edit. If null, this is a reply.
  final int? parentId; // For replies

  const EditReplyCommentDialog({
    super.key,
    required this.postId,
    this.comment,
    this.parentId,
  });

  @override
  ConsumerState<EditReplyCommentDialog> createState() =>
      _EditReplyCommentDialogState();
}

class _EditReplyCommentDialogState
    extends ConsumerState<EditReplyCommentDialog> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  List<PostMedia> _selectedMedia = [];
  bool _isUploading = false;
  bool _isSubmitting = false; // Guard to prevent double submission
  bool _hasClosedModal = false; // Guard to prevent double modal close
  int _apiCallCount = 0; // Track number of API calls

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill content and media
    if (widget.comment != null) {
      _contentController.text = widget.comment!.content;
      if (widget.comment!.media != null && widget.comment!.media!.isNotEmpty) {
        _selectedMedia = List<PostMedia>.from(widget.comment!.media!);
        print('📝 [EditDialog] Loaded ${_selectedMedia.length} existing media');
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.comment != null;
  bool get _isReplying => widget.parentId != null;

  String get _dialogTitle {
    if (_isEditing) return 'Edit Comment';
    if (_isReplying) return 'Reply to Comment';
    return 'Add Comment';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_dialogTitle),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: _isReplying
                      ? 'Write your reply...'
                      : 'Write your comment...',
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_selectedMedia.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Attached Media:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedMedia.asMap().entries.map((entry) {
                    final index = entry.key;
                    final media = entry.value;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            media.mediaUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error, size: 20),
                              );
                            },
                          ),
                        ),
                        if (media.mediaType == 'VIDEO')
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.play_circle_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMedia.removeAt(index);
                              });
                            },
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (!_isUploading)
          TextButton.icon(
            onPressed: _showMediaPicker,
            icon: const Icon(Icons.attach_file),
            label: const Text('Media'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (_isUploading || _isSubmitting) ? null : _submitComment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D09E),
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(_isEditing ? 'Update' : 'Post'),
        ),
      ],
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Media',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  icon: Icons.photo_camera,
                  label: 'Camera',
                  onTap: () => _pickMedia(ImageSource.camera, 'IMAGE'),
                ),
                _buildMediaOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickMedia(ImageSource.gallery, 'IMAGE'),
                ),
                _buildMediaOption(
                  icon: Icons.videocam,
                  label: 'Video',
                  onTap: () => _pickMedia(ImageSource.gallery, 'VIDEO'),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: const Color(0xFF00D09E), size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source, String mediaType) async {
    try {
      setState(() => _isUploading = true);

      XFile? file;
      if (mediaType == 'VIDEO') {
        file = await _imagePicker.pickVideo(source: source);
      } else {
        file = await _imagePicker.pickImage(source: source);
      }

      if (file != null) {
        String uploadUrl;
        if (mediaType == 'IMAGE') {
          uploadUrl = await _cloudinaryService.uploadImage(File(file.path));
        } else {
          uploadUrl = await _cloudinaryService.uploadVideo(File(file.path));
        }

        setState(() {
          _selectedMedia.add(PostMedia(
            id: 0,
            mediaUrl: uploadUrl,
            mediaType: mediaType,
          ));
        });

        if (mounted) {
          Flushbar(
            message: 'Media uploaded successfully!',
            icon: const Icon(Icons.check_circle, color: Colors.white),
            backgroundColor: const Color(0xFF00D09E),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        }
      }
    } catch (e) {
      if (mounted) {
        Flushbar(
          message: 'Error uploading media: $e',
          icon: const Icon(Icons.error_outline, color: Colors.white),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _submitComment() async {
    // Prevent double submission
    if (_isSubmitting) {
      print('⚠️ [EditReplyCommentDialog] Already submitting, ignoring duplicate call');
      return;
    }

    final content = _contentController.text.trim();
    // Allow submission if either content OR media exists
    if (content.isEmpty && _selectedMedia.isEmpty) {
      Flushbar(
        message: 'Please enter text or add media',
        icon: const Icon(Icons.warning, color: Colors.white),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _apiCallCount++;
    });
    
    print('📝 [EditReplyCommentDialog] Submitting ${_isEditing ? "edit" : _isReplying ? "reply" : "comment"}...');
    print('🔢 [EditReplyCommentDialog] API Call Count: $_apiCallCount');
    print('📦 [EditReplyCommentDialog] PostId: ${widget.postId}');
    print('📦 [EditReplyCommentDialog] ParentId: ${widget.parentId}');
    print('📦 [EditReplyCommentDialog] Is Reply: $_isReplying');
    print('📦 [EditReplyCommentDialog] Content length: ${content.length}');
    print('📦 [EditReplyCommentDialog] Media count: ${_selectedMedia.length}');
    
    if (_apiCallCount > 1) {
      print('⚠️⚠️⚠️ [EditReplyCommentDialog] DUPLICATE API CALL DETECTED! Count: $_apiCallCount');
    }

    try {
      if (_isEditing) {
        // Update existing comment
        print('✏️ [EditReplyCommentDialog] Calling updateComment API...');
        await ref.read(commentViewModelProvider.notifier).updateComment(
              commentId: widget.comment!.id,
              content: content,
              media: _selectedMedia.isNotEmpty ? _selectedMedia : null,
            );

        print('✅ [EditReplyCommentDialog] Comment updated successfully');
        
        if (mounted) {
          setState(() => _isSubmitting = false);
          Navigator.pop(context, true);
          Flushbar(
            message: 'Comment updated successfully!',
            icon: const Icon(Icons.check_circle, color: Colors.white),
            backgroundColor: const Color(0xFF00D09E),
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
          ).show(context);
        }
      } else {
        // Create new comment or reply
        print('📝 [EditReplyCommentDialog] Calling createComment API...');
        await ref.read(commentViewModelProvider.notifier).createComment(
              postId: widget.postId,
              content: content,
              parentId: widget.parentId,
              media: _selectedMedia.isNotEmpty ? _selectedMedia : null,
            );

        print('✅ [EditReplyCommentDialog] Comment ${widget.parentId != null ? "reply" : "root"} created successfully');
        
        if (mounted && !_hasClosedModal) {
          setState(() {
            _isSubmitting = false;
            _hasClosedModal = true;
          });
          
          print('🚪 [EditReplyCommentDialog] Closing modal with success=true');
          // Return true to indicate success - parent will show Flushbar
          Navigator.pop(context, true);
        } else if (_hasClosedModal) {
          print('⚠️ [EditReplyCommentDialog] Modal already closed, skipping duplicate close');
        }
      }
    } catch (e) {
      print('❌ [EditReplyCommentDialog] Error submitting comment: $e');
      
      if (mounted) {
        setState(() => _isSubmitting = false);
        Flushbar(
          message: 'Error: $e',
          icon: const Icon(Icons.error_outline, color: Colors.white),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
        ).show(context);
      }
    }
  }
}
