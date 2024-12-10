import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../../../floating dev id.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  const FullScreenVideoPlayer(this.videoPlayerController, {super.key});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isVolumeSliderVisible = false;
  bool _isDisposed = false;
  bool showStatus = false;
  String statusText = '';
  Timer? _statusTimer;
  late Timer _positionTimer;

  @override
  void initState() {
    super.initState();
    _controller = widget.videoPlayerController;

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      if (mounted && !_isDisposed) {
        setState(() {});
      }
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller.setVolume(1.0);

    // Remove automatic play
    // _controller.play(); // Removed

    _positionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_controller.value.isPlaying && mounted && !_isDisposed) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _statusTimer?.cancel();
    _positionTimer.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _showStatus("Pause");
    } else {
      _controller.play();
      _showStatus("Play");
    }
  }

  void _showStatus(String text) {
    setState(() {
      statusText = text;
      showStatus = true;
    });
    _statusTimer?.cancel();
    _statusTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        showStatus = false;
      });
    });
  }

  String _formatDuration(Duration position) {
    if (_isDisposed) return "0:00:00";
    final hours = position.inHours;
    final minutes = position.inMinutes.remainder(60);
    final seconds = position.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && !_isDisposed) {
            return Stack(
              children: [
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_isVolumeSliderVisible && !_isDisposed)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.volume_up, color: Colors.white),
                                        Expanded(
                                          child: Slider(
                                            value: _controller.value.volume,
                                            min: 0,
                                            max: 1,
                                            onChanged: (value) {
                                              if (mounted && !_isDisposed) {
                                                setState(() {
                                                  _controller.setVolume(value);
                                                });
                                              }
                                            },
                                            activeColor: Colors.white,
                                            inactiveColor: Colors.white38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildIconButton(
                                icon: _controller.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                onPressed: _togglePlayPause,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _formatDuration(_controller.value.position),
                                style: TextStyle(color: Colors.white),
                              ),
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    VideoProgressIndicator(
                                      _controller,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                        playedColor: Colors.white,
                                        bufferedColor: Colors.white70,
                                        backgroundColor: Colors.white30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              _buildIconButton(
                                icon: Icons.volume_up,
                                onPressed: () {
                                  setState(() {
                                    _isVolumeSliderVisible = !_isVolumeSliderVisible;
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: _buildIconButton(
                    icon: Icons.close,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                if (showStatus)
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                if (!_isDisposed) FloatingDeviceInfoWidget(),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
