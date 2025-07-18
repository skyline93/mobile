// lib/ui/video/widgets/home_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:gbox/ui/video/view_model/video_view_model.dart';
import 'package:gbox/ui/video/widgets/video_list_widget.dart';

/// The main screen of the application.
///
/// It displays a list of available videos and provides actions to refresh the list
/// and upload a new video. It follows the architecture by acting as a "dumb"
/// widget that gets its state from a [VideoViewModel] and delegates user
/// actions to it.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // When the screen is first built, trigger an initial fetch of the video list.
    // We use Future.microtask to ensure that the context is available for `read`.
    Future.microtask(() => context.read<VideoViewModel>().fetchVideos());
  }

  /// Handles the entire process of picking a video from the gallery and uploading it.
  Future<void> _pickAndUploadVideo() async {
    // We use context.read because this is a one-time action, not for rebuilding.
    final videoViewModel = context.read<VideoViewModel>();
    final picker = ImagePicker();

    // Let the user pick a video from their gallery.
    final XFile? videoFile =
        await picker.pickVideo(source: ImageSource.gallery);

    // If the user cancels the picker, do nothing.
    if (videoFile == null || !mounted) return;

    // Show a dialog to get the video title from the user.
    final String? title = await _showTitleDialog();

    // If a title was provided, proceed with the upload.
    if (title != null && title.isNotEmpty) {
      // Give immediate feedback to the user that the upload has started.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading video...')),
      );

      final bool success =
          await videoViewModel.uploadVideo(File(videoFile.path), title);

      // After the upload attempt, show the result.
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Upload accepted! Video is processing.'
              : 'Upload failed.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  /// Displays a dialog to prompt the user for a video title.
  Future<String?> _showTitleDialog() {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Video Title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'My Awesome Video'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Upload'),
            onPressed: () => Navigator.of(context).pop(controller.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean Architecture Video App'),
        actions: [
          // Refresh button that triggers a re-fetch of the video list.
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<VideoViewModel>().fetchVideos(),
          ),
        ],
      ),
      // The body uses a Consumer to reactively build the UI based on the ViewModel's state.
      body: Consumer<VideoViewModel>(
        builder: (context, viewModel, child) {
          // Show a loading indicator while fetching for the first time.
          if (viewModel.isLoading && viewModel.videos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show an error message if something went wrong.
          if (viewModel.errorMessage != null) {
            return Center(
                child: Text('An error occurred: ${viewModel.errorMessage}'));
          }
          // If data is available, display it using a dedicated list widget.
          return VideoListWidget(videos: viewModel.videos);
        },
      ),
      // The FloatingActionButton triggers the video upload process.
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadVideo,
        tooltip: 'Upload Video',
        child: const Icon(Icons.upload),
      ),
    );
  }
}
