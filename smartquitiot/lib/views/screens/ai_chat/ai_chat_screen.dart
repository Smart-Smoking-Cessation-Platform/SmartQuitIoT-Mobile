import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_message_bubble.dart';
import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_enhanced_input.dart';
import 'package:SmartQuitIoT/providers/chatbot_provider.dart';
import 'package:SmartQuitIoT/models/chat_message.dart';
import 'package:SmartQuitIoT/services/cloudinary_service.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AiChatEnhancedInputState> _inputKey = GlobalKey();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  List<File> _selectedImages = [];
  List<File> _selectedVideos = [];
  bool _isUploadingMedia = false;

  @override
  void initState() {
    super.initState();
    // Initialize chatbot when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatbotViewModelProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showFlushbar(String message, {bool isError = false}) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.red : const Color(0xFF00D09E),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatbotViewModelProvider);

    // Listen for errors
    ref.listen(chatbotViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        _showFlushbar(next.errorMessage!, isError: true);
        ref.read(chatbotViewModelProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(
          height: 40,
          child: Image.asset('lib/assets/logo/logo-2.png', fit: BoxFit.contain),
        ),
        centerTitle: true,
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: chatState.isConnected
                      ? Colors.white
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: chatState.isConnected
                        ? Colors.green[700]!
                        : Colors.orange[700]!,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: chatState.isConnected
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: chatState.isConnected
                            ? Colors.green[700]
                            : Colors.orange[700],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      chatState.isConnected ? 'Online' : 'Connecting...',
                      style: TextStyle(
                        color: chatState.isConnected
                            ? Colors.green[900]
                            : Colors.orange[900],
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.read(chatbotViewModelProvider.notifier).reloadHistory();
            },
          ),
        ],
      ),
      body: chatState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: chatState.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start a conversation with AI!',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: chatState.messages.length,
                          itemBuilder: (context, index) {
                            final message = chatState.messages[index];
                            return AiChatMessageBubble(
                              text: message.text,
                              isUser: message.isUser,
                              time: _formatTime(message.timestamp),
                              media: message.media,
                              isLoading: message.isLoading,
                            );
                          },
                        ),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageInput() {
    final chatState = ref.watch(chatbotViewModelProvider);

    return AiChatEnhancedInput(
      key: _inputKey,
      controller: _messageController,
      isUploading: _isUploadingMedia || chatState.isSending,
      onMediaSelected: (images, videos) {
        setState(() {
          _selectedImages = images;
          _selectedVideos = videos;
        });
      },
      onSubmitted: (text) {
        if (text.trim().isNotEmpty ||
            _selectedImages.isNotEmpty ||
            _selectedVideos.isNotEmpty) {
          _sendMessage();
        }
      },
      onSend: () {
        if (_messageController.text.trim().isNotEmpty ||
            _selectedImages.isNotEmpty ||
            _selectedVideos.isNotEmpty) {
          _sendMessage();
        }
      },
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty && _selectedImages.isEmpty && _selectedVideos.isEmpty) {
      return;
    }

    if (!ref.read(chatbotViewModelProvider).isConnected) {
      _showFlushbar('Not connected to server. Please wait...', isError: true);
      return;
    }

    try {
      List<ChatMessageMedia>? mediaList;

      // Upload media to Cloudinary if any
      if (_selectedImages.isNotEmpty || _selectedVideos.isNotEmpty) {
        setState(() => _isUploadingMedia = true);

        mediaList = [];

        // Upload images
        for (final imageFile in _selectedImages) {
          try {
            debugPrint('📤 Uploading image to Cloudinary...');
            final imageUrl = await _cloudinaryService.uploadImage(imageFile);
            mediaList.add(
              ChatMessageMedia(mediaUrl: imageUrl, mediaType: 'IMAGE'),
            );
            debugPrint('✅ Image uploaded: $imageUrl');
          } catch (e) {
            debugPrint('❌ Error uploading image: $e');
            _showFlushbar('Failed to upload image', isError: true);
          }
        }

        // Upload videos
        for (final videoFile in _selectedVideos) {
          try {
            debugPrint('📤 Uploading video to Cloudinary...');
            final videoUrl = await _cloudinaryService.uploadVideo(videoFile);
            mediaList.add(
              ChatMessageMedia(mediaUrl: videoUrl, mediaType: 'VIDEO'),
            );
            debugPrint('✅ Video uploaded: $videoUrl');
          } catch (e) {
            debugPrint('❌ Error uploading video: $e');
            _showFlushbar('Failed to upload video', isError: true);
          }
        }

        setState(() => _isUploadingMedia = false);
      }

      // Send message via ViewModel
      await ref
          .read(chatbotViewModelProvider.notifier)
          .sendMessage(text.isNotEmpty ? text : '(Sent media)', mediaList);

      // Clear input
      _messageController.clear();
      setState(() {
        _selectedImages.clear();
        _selectedVideos.clear();
      });
      _inputKey.currentState?.clearMedia();

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      setState(() => _isUploadingMedia = false);
      _showFlushbar('Failed to send message: $e', isError: true);
    }
  }
}
