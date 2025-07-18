// data/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gbox/config/app_config.dart';
import 'package:gbox/data/model/video_api_model.dart';

typedef JsonToType<T> = T Function(dynamic json);

class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  bool get isSuccess => code == 0;

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, {
        JsonToType<T>? fromJsonData,
  }){
    T? parseData;
    if (json.containsKey('data') && json['data'] !=null && fromJsonData !=null){
      parseData = fromJsonData(json['data']);
    } else if (json.containsKey('data') && json['data'] != null && T == dynamic){
      parseData = json['data'] as T?;
    } else if (T == Null) {
      parseData = null;
    }

    return ApiResponse<T>(
      code: json['code'] as int,
      message: json['message'] as String,
      data: parseData,
    );
  }
}

class ApiService {
  final String _baseUrl = AppConfig.apiBaseUrl;
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<ApiResponse<T>> _get<T>(String endpoint, {JsonToType<T>? fromJsonData}) async {
    final response = await _client.get(Uri.parse('$_baseUrl/$endpoint'));

    if (response.statusCode == 200) {
      return ApiResponse.fromJson(jsonDecode(response.body), fromJsonData: fromJsonData);
    } else {
      try {
        Map<String, dynamic> errorBody = jsonDecode(response.body);
        if (errorBody.containsKey('code') && errorBody.containsKey('message')){
          return ApiResponse<T>.fromJson(errorBody, fromJsonData: null);
        }
      }catch (e){
        throw Exception('Failed to load data from API. Status code: ${response.statusCode}');
      }
      throw Exception('Failed to load data from API. Status code: ${response.statusCode}');
    }
  }

  Future<List<VideoApiModel>> fetchVideos() async {
    final response = await _get<List<VideoApiModel>>(
        'api/videos',
        fromJsonData: (jsonData) {
          if (jsonData is List) {
            return VideoApiModel.listFromJson(jsonData);
          }
          throw FormatException('Invalid data format');
        },
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }else {
      throw Exception('Failed to load videos from API. Status code: ${response.code}');
    }
  }

  Future<bool> uploadVideo(File videoFile, String title) async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/videos'));
    request.fields['title'] = title;
    request.files
        .add(await http.MultipartFile.fromPath('video', videoFile.path));

    var response = await request.send();
    return response.statusCode == 202;
  }
}
