import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gbox/data/repositories/video_repository.dart';
import 'package:gbox/domain/models/video.dart';

class VideoViewModel with ChangeNotifier {
  final VideoRepository _videoRepository;

  VideoViewModel(this._videoRepository);

  List<Video> _videos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Video> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchVideos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _videos = await _videoRepository.getVideos();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadVideo(File videoFile, String title) async {
    try {
      final success = await _videoRepository.uploadVideo(videoFile, title);
      if (success) {
        Future.delayed(const Duration(seconds: 5), fetchVideos);
      }
      return success;
    } catch (e) {
      debugPrint("Upload failed in ViewModel: $e");
      return false;
    }
  }
}
