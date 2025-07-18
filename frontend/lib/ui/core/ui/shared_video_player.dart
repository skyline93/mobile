// lib/ui/core/ui/shared_video_player.dart

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class SharedVideoPlayer extends StatefulWidget {
  /// The HLS (m3u8) URL of the video to be played.
  final String hlsUrl;

  const SharedVideoPlayer({
    Key? key,
    required this.hlsUrl,
  }) : super(key: key);

  @override
  State<SharedVideoPlayer> createState() => _SharedVideoPlayerState();
}

class _SharedVideoPlayerState extends State<SharedVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  // Track the state of initialization to show appropriate UI
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Create a controller for the video from the network URL
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.hlsUrl),
      );

      // Initialize the controller. This will download metadata for the video.
      await _videoPlayerController.initialize();

      // Create a Chewie controller to provide a standard UI.
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true, // Start playing the video as soon as it's ready.
        looping: false, // Don't loop the video.

        // Customizations for the player UI
        placeholder: const Center(
            child: CircularProgressIndicator()), // Shown while video is loading
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error playing video: $errorMessage',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        },

        // Enforce aspect ratio
        autoInitialize: true, // Chewie handles initialization
        aspectRatio: _videoPlayerController.value.aspectRatio,

        // Allow fullscreen
        allowedScreenSleep: false, // Prevent screen from sleeping
        allowFullScreen: true,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
      );

      // Update the state to rebuild the widget with the player.
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      // Handle initialization errors (e.g., network error, invalid URL)
      debugPrint('Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // IMPORTANT: Dispose of the controllers to free up resources.
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // If an error occurred during initialization, show an error message.
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Could not load video.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_isInitialized && _chewieController != null) {
      // If the player is initialized, show the Chewie player.
      return Chewie(
        controller: _chewieController!,
      );
    }

    // While initializing, show a loading indicator.
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
