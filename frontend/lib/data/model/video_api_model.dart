import 'package:gbox/domain/models/video.dart';

class VideoApiModel {
  final String uuid;
  final String title;
  final String thumbnailUrl; // 匹配JSON key 'thumbnail_url'

  VideoApiModel(
      {required this.uuid, required this.title, required this.thumbnailUrl});

  factory VideoApiModel.fromJson(Map<String, dynamic> json) {
    return VideoApiModel(
      uuid: json['uuid'],
      title: json['title'],
      thumbnailUrl: json['thumbnail_url'],
    );
  }

  static List<VideoApiModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((item) => VideoApiModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  // 转换成业务层（Domain）模型
  Video toDomainModel() {
    return Video(
      uuid: uuid,
      title: title,
      thumbnailUrl: thumbnailUrl,
    );
  }
}
