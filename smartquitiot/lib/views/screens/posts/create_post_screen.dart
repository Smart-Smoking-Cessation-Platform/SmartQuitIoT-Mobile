import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:SmartQuitIoT/services/cloudinary_service.dart';
import 'package:SmartQuitIoT/providers/post_provider.dart';
import '../../../models/post.dart';
import '../../../utils/notification_helper.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final Post? post;
  const CreatePostScreen({super.key, this.post});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  late quill.QuillController _quillController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _editorFocusNode = FocusNode();

  bool _isLoading = false;
  String? _thumbnailUrl;
  List<Map<String, String>> _mediaList = [];

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();

    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _descriptionController.text = widget.post!.description ?? '';
      _thumbnailUrl = widget.post!.thumbnail;
      if (widget.post!.media != null) {
        _mediaList = widget.post!.media!
            .map(
              (m) => {
                'mediaUrl': m.mediaUrl,
                'mediaType': m.mediaType,
                'thumbUrl': m.mediaType == 'VIDEO' ? m.mediaUrl : '',
              },
            )
            .toList();
      }
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        title: Text(
          widget.post != null ? 'Edit Post' : 'Create Post',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading ? _buildLoading() : _buildBody(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF00D09E)),
          ),
          SizedBox(height: 16),
          Text('Uploading...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Title',
            hint: 'Enter post title',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Enter a short description',
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          _buildThumbnailPicker(),
          const SizedBox(height: 20),
          _buildMediaSection(),
          const SizedBox(height: 20),
          _buildRichTextEditor(),
          const SizedBox(height: 30),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00D09E), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnailPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thumbnail',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickThumbnail,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _thumbnailUrl != null && _thumbnailUrl!.isNotEmpty
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _thumbnailUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => setState(() => _thumbnailUrl = null),
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Tap to upload thumbnail',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Media',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._mediaList.map((media) {
              final isVideo = media['mediaType'] == 'VIDEO';
              final thumbData = media['thumbUrl']?.isNotEmpty == true
                  ? Image.memory(
                      base64Decode(media['thumbUrl']!),
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    )
                  : null;

              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: isVideo
                        ? Stack(
                            children: [
                              if (thumbData != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: thumbData,
                                ),
                              const Center(
                                child: Icon(
                                  Icons.play_circle_fill,
                                  size: 40,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              media['mediaUrl']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _mediaList.remove(media)),
                    ),
                  ),
                ],
              );
            }),
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.grey,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRichTextEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              quill.QuillSimpleToolbar(
                controller: _quillController,
                config: const quill.QuillSimpleToolbarConfig(
                  multiRowsDisplay: false,
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showColorButton: true,
                  showHeaderStyle: true,
                  showAlignmentButtons: true,
                  showListBullets: false,
                  showListNumbers: false,
                  showListCheck: false,
                  showQuote: false,
                  showCodeBlock: false,
                  showInlineCode: false,
                  showStrikeThrough: false,
                  showLink: false,
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 300,
                    maxHeight: 600,
                  ),
                  child: SingleChildScrollView(
                    child: quill.QuillEditor.basic(
                      controller: _quillController,
                      focusNode: _editorFocusNode,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _savePost,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D09E),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'Save Post',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _pickThumbnail() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() => _isLoading = true);
        final url = await CloudinaryService().uploadImage(File(image.path));
        setState(() {
          _thumbnailUrl = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMedia() async {
    final XFile? file = await _imagePicker.pickMedia();
    if (file != null) {
      setState(() => _isLoading = true);
      try {
        String url;
        String type;
        String? thumbUrl;

        if (file.path.endsWith('.mp4')) {
          url = await CloudinaryService().uploadVideo(File(file.path));
          type = 'VIDEO';

          // Tạo thumbnail
          final uint8list = await VideoThumbnail.thumbnailData(
            video: file.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 150,
            quality: 75,
          );
          if (uint8list != null) {
            thumbUrl = 'data:image/jpeg;base64,${base64Encode(uint8list)}';
          }
        } else {
          url = await CloudinaryService().uploadImage(File(file.path));
          type = 'IMAGE';
        }

        setState(() {
          _mediaList.add({
            'mediaUrl': url,
            'mediaType': type,
            'thumbUrl': thumbUrl ?? '',
          });
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _savePost() async {
    if (_titleController.text.trim().isEmpty) {
      NotificationHelper.showTopNotification(
        context,
        title: 'Error',
        message: 'Title cannot be empty',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final postData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'content': _quillController.document.toPlainText().trim(),
      'thumbnail': _thumbnailUrl ?? '',
      'media': _mediaList,
    };

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF00D09E)),
        ),
      ),
    );

    try {
      if (widget.post != null) {
        await ref
            .read(postViewModelProvider.notifier)
            .updatePost(widget.post!.id, postData);
        NotificationHelper.showTopNotification(
          context,
          title: 'Success',
          message: 'Post updated successfully!',
        );
      } else {
        await ref.read(postViewModelProvider.notifier).createPost(postData);
        NotificationHelper.showTopNotification(
          context,
          title: 'Success',
          message: 'Post created successfully!',
        );
      }

      if (mounted) {
        // Pop dialog
        Navigator.of(context, rootNavigator: true).pop();

        // Pop screen
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      NotificationHelper.showTopNotification(
        context,
        title: 'Error',
        message: 'Failed to save post: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
