// ui/video/widgets/player_screen.dart
import 'package:flutter/material.dart';
import 'package:gbox/config/app_config.dart';
import 'package:gbox/ui/core/ui/shared_video_player.dart';

class PlayerScreen extends StatelessWidget {
  final String videoUuid;
  final String videoTitle;

  const PlayerScreen(
      {Key? key, required this.videoUuid, required this.videoTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hlsUrl = '${AppConfig.apiBaseUrl}/media/$videoUuid/playlist.m3u8';

    return Scaffold(
      appBar: AppBar(title: Text(videoTitle)),
      body: Center(
        child: SharedVideoPlayer(hlsUrl: hlsUrl), // Use the shared widget
      ),
    );
  }
}
