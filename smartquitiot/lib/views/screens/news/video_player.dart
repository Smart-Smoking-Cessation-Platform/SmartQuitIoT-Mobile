import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
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
    });
  }

  void _openFullscreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(videoUrl: widget.videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
        ),
      );
    }

    return GestureDetector(
      onTap: _openFullscreen,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          // Play overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// Fullscreen Video Player
class FullscreenVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const FullscreenVideoPlayer({super.key, required this.videoUrl});

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _isInitialized = false;
  bool _isMuted = false;
  bool _isSeeking = false;
  double? _seekPosition; // Lưu vị trí tạm khi đang kéo slider

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
          _controller.setVolume(1.0);
        }
      });

    // Add listener để update UI khi video đang chạy
    _controller.addListener(() {
      if (mounted && !_isSeeking) {
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
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _seekTo(Duration position) {
    _controller.seekTo(position).then((_) {
      if (mounted) {
        setState(() {
          _isSeeking = false;
          _seekPosition = null;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
              ),
            )
          : GestureDetector(
              onTap: _toggleControls,
              child: Stack(
                children: [
                  // Video player
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),

                  // Controls overlay
                  if (_showControls)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Column(
                        children: [
                          // Top bar
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const Spacer(),
                                  // Volume button
                                  IconButton(
                                    icon: Icon(
                                      _isMuted
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    onPressed: _toggleMute,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Play/Pause button
                          IconButton(
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              size: 72,
                              color: Colors.white,
                            ),
                            onPressed: _togglePlayPause,
                          ),

                          const Spacer(),

                          // Bottom controls
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              children: [
                                // Progress bar with slider
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: const Color(0xFF00D09E),
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: const Color(0xFF00D09E),
                                    overlayColor: const Color(
                                      0xFF00D09E,
                                    ).withOpacity(0.3),
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
                                    ),
                                    trackHeight: 4,
                                  ),
                                  child: Slider(
                                    // Hiển thị vị trí tạm khi đang seek, không thì hiển thị vị trí thực
                                    value: (_isSeeking && _seekPosition != null)
                                        ? _seekPosition!
                                        : _controller.value.position.inSeconds
                                              .toDouble()
                                              .clamp(
                                                0.0,
                                                _controller
                                                    .value
                                                    .duration
                                                    .inSeconds
                                                    .toDouble()
                                                    .clamp(
                                                      1.0,
                                                      double.infinity,
                                                    ),
                                              ),
                                    min: 0,
                                    max:
                                        _controller.value.duration.inSeconds > 0
                                        ? _controller.value.duration.inSeconds
                                              .toDouble()
                                        : 1.0,
                                    onChangeStart: (value) {
                                      setState(() {
                                        _isSeeking = true;
                                        _seekPosition = value;
                                      });
                                    },
                                    onChanged: (value) {
                                      // Cập nhật vị trí tạm khi user kéo slider
                                      setState(() {
                                        _seekPosition = value;
                                      });
                                    },
                                    onChangeEnd: (value) {
                                      // Seek khi user thả tay ra
                                      _seekTo(Duration(seconds: value.toInt()));
                                    },
                                  ),
                                ),
                                // Time display
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        // Hiển thị thời gian tạm khi đang seek
                                        _formatDuration(
                                          _isSeeking && _seekPosition != null
                                              ? Duration(
                                                  seconds: _seekPosition!
                                                      .toInt(),
                                                )
                                              : _controller.value.position,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        _formatDuration(
                                          _controller.value.duration,
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
