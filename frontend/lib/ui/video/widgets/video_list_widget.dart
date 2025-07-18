// ui/video/widgets/video_list_widget.dart
import 'package:flutter/material.dart';
import 'package:gbox/domain/models/video.dart';
import 'package:gbox/routing/app_router.dart';

class VideoListWidget extends StatelessWidget {
  final List<Video> videos;

  const VideoListWidget({Key? key, required this.videos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const Center(child: Text('No videos found. Upload one!'));
    }

    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return ListTile(
          leading: Image.network(
            video.thumbnailUrl,
            width: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.videocam, size: 50, color: Colors.grey),
          ),
          title: Text(video.title),
          subtitle: Text('UUID: ${video.uuid}'),
          onTap: () => AppRouter.navigateToPlayer(context, video),
        );
      },
    );
  }
}
