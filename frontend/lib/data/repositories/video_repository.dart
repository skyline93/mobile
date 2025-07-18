// data/repositories/video_repository.dart
import 'dart:io';
import 'package:gbox/domain/models/video.dart';
import 'package:gbox/data/services/api_services.dart';

class VideoRepository {
  final ApiService _apiService;

  VideoRepository(this._apiService);

  Future<List<Video>> getVideos() async {
    try {
      final apiModels = await _apiService.fetchVideos();
      // 将数据层模型转换为领域层模型
      return apiModels.map((apiModel) => apiModel.toDomainModel()).toList();
    } catch (e) {
      // 在这里可以处理错误，比如记录日志
      rethrow; // 重新抛出，让上层处理
    }
  }

  Future<bool> uploadVideo(File videoFile, String title) async {
    return await _apiService.uploadVideo(videoFile, title);
  }
}
