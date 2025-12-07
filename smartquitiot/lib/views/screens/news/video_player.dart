import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

// ---------------------------------------------------------
// WIDGET 1: VIDEO PREVIEW (NHỎ) - KHÔNG ĐỔI
// ---------------------------------------------------------
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullscreen() {
    // Pause video nhỏ trước khi mở full
    _controller.pause(); 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(videoUrl: widget.videoUrl),
      ),
    ).then((_) {
      // Khi quay lại thì reload state nếu cần
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container(
        height: 200,
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
        child: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)))),
      );
    }

    return GestureDetector(
      onTap: _openFullscreen,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
              child: const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// WIDGET 2: FULLSCREEN PLAYER (ĐÃ FIX LỖI TUA + DURATION)
// ---------------------------------------------------------
class FullscreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const FullscreenVideoPlayer({super.key, required this.videoUrl});

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  
  // BIẾN QUAN TRỌNG ĐỂ FIX LỖI TUA
  bool _isDragging = false; 
  double _dragValue = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.play();
        }
      });

    // Lắng nghe cập nhật của video
    _controller.addListener(() {
      if (mounted && !_isDragging) {
        // Chỉ setState cập nhật UI khi người dùng KHÔNG đang kéo thanh trượt
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _showControls = true;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy tổng thời gian video
    final duration = _controller.value.duration;
    final totalSeconds = duration.inSeconds.toDouble();

    // 2. Tính vị trí hiện tại: 
    // Nếu đang kéo (_isDragging) -> lấy giá trị ngón tay (_dragValue)
    // Nếu đang chạy tự động -> lấy từ controller
    double currentSeconds = _isDragging 
        ? _dragValue 
        : _controller.value.position.inSeconds.toDouble();

    // 3. Fix lỗi an toàn (tránh Slider bị lỗi khi duration = 0)
    if (currentSeconds < 0) currentSeconds = 0;
    if (totalSeconds > 0 && currentSeconds > totalSeconds) currentSeconds = totalSeconds;
    
    // Nếu video chưa load duration xong thì disable thanh slider tạm thời
    final bool canSeek = totalSeconds > 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E))))
          : GestureDetector(
              onTap: () => setState(() => _showControls = !_showControls),
              child: Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),

                  // CONTROLS OVERLAY
                  if (_showControls) ...[
                    // Nút Close
                    Positioned(
                      top: 40, left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Nút Play ở giữa (chỉ hiện khi pause)
                    if (!_controller.value.isPlaying && !_isDragging)
                      Center(
                        child: IconButton(
                          iconSize: 80,
                          icon: const Icon(Icons.play_circle_fill, color: Colors.white54),
                          onPressed: _togglePlayPause,
                        ),
                      ),

                    // THANH ĐIỀU KHIỂN DƯỚI ĐÁY
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          children: [
                            // Nút Play/Pause nhỏ
                            GestureDetector(
                              onTap: _togglePlayPause,
                              child: Icon(
                                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Thời gian hiện tại
                            Text(
                              _formatDuration(Duration(seconds: currentSeconds.toInt())),
                              style: const TextStyle(color: Colors.white),
                            ),

                            // SLIDER (Thanh tua)
                            Expanded(
                              child: Slider(
                                activeColor: const Color(0xFF00D09E),
                                inactiveColor: Colors.grey,
                                min: 0,
                                max: canSeek ? totalSeconds : 1.0, // Nếu chưa có duration thì max = 1 để ko lỗi
                                value: canSeek ? currentSeconds : 0.0,
                                
                                // BẮT ĐẦU KÉO -> Dừng update từ video
                                onChangeStart: (value) {
                                  setState(() {
                                    _isDragging = true;
                                    _dragValue = value;
                                  });
                                },
                                
                                // ĐANG KÉO -> Cập nhật số hiển thị theo tay
                                onChanged: (value) {
                                  if (!canSeek) return;
                                  setState(() {
                                    _dragValue = value;
                                  });
                                },
                                
                                // THẢ TAY -> Mới thực sự tua video
                                onChangeEnd: (value) {
                                  if (!canSeek) return;
                                  _controller.seekTo(Duration(seconds: value.toInt()));
                                  setState(() {
                                    _isDragging = false;
                                  });
                                  // Tự động play lại nếu đang pause
                                  if (!_controller.value.isPlaying) {
                                     _controller.play();
                                  }
                                },
                              ),
                            ),

                            // Tổng thời gian
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}