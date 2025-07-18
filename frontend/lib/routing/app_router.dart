// routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:gbox/domain/models/video.dart';
import 'package:gbox/ui/video/widgets/player_screen.dart';

class AppRouter {
  static void navigateToPlayer(BuildContext context, Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          videoUuid: video.uuid,
          videoTitle: video.title,
        ),
      ),
    );
  }
}
