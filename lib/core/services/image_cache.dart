import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/config/config.dart';

class ImageCacheService {
  static late Dio _imageDio;
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;

    _imageDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.bytes,
    ),);

    _initialized = true;
  }

  /// 获取配置好的Dio实例用于图片下载
  static Dio get imageDio {
    if (!_initialized) {
      initialize();
    }
    return _imageDio;
  }

  /// 创建一个自定义的CachedNetworkImage，支持开发环境HTTPS
  static CachedNetworkImage buildImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit? fit,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, Object)? errorWidget,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      httpHeaders: const {
        'User-Agent': 'GBox-Mobile/${ApiConfig.apiVersion}',
      },
      placeholder: placeholder ??
              (context, url) => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      errorWidget: errorWidget ??
              (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.error_outline,
              color: Colors.grey,
            ),
          ),
    );
  }
}
