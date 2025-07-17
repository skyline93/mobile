import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/config/config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 认证状态通知器
class AuthStatusNotifier extends StateNotifier<AuthStatus> {
  AuthStatusNotifier() : super(AuthStatus.unknown);

  void setAuthenticated() {
    state = AuthStatus.authenticated;
  }

  void setUnauthenticated() {
    state = AuthStatus.unauthenticated;
  }

  void setUnknown() {
    state = AuthStatus.unknown;
  }
}

// 认证状态枚举
enum AuthStatus { unknown, authenticated, unauthenticated }

// 认证状态提供者
final authStatusProvider =
    StateNotifierProvider<AuthStatusNotifier, AuthStatus>((ref) {
      return AuthStatusNotifier();
    });

class ApiClient {
  ApiClient({required FlutterSecureStorage secureStorage, required Ref ref})
    : _secureStorage = secureStorage,
      _ref = ref {
    _dio = Dio(
      BaseOptions(
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
      ),
    );

    // 添加拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加认证token
          final token = await _secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = token;
          }

          final serverUrl = await getServerUrl();
          if (serverUrl.isNotEmpty) {
            options.baseUrl = serverUrl;

            if (!options.path.startsWith('/')) {
              options.path = '/${options.path}';
            }
            options.path = '/api/${ApiConfig.apiVersion}${options.path}';
          }

          if (kDebugMode) {
            print('🌐 API请求: ${options.baseUrl}${options.path}');
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('❌ API错误: ${error.message}');
            print('请求URL: ${error.requestOptions.uri}');
            print('状态码: ${error.response?.statusCode}');
            if (error.response?.data != null) {
              print('响应数据: ${error.response?.data}');
            }
          }

          // 不处理刷新令牌请求本身的错误，避免循环
          if (error.requestOptions.path.contains('/auth/refresh')) {
            handler.next(error);
            return;
          }

          if (error.response?.statusCode == 401) {
            // 通知认证状态变化，但不立即设置为未认证，等待刷新令牌尝试
            _ref.read(authStatusProvider.notifier).setUnknown();

            if (kDebugMode) {
              print('🔑 检测到401错误，令牌可能已过期');
            }

            // 我们不在这里处理刷新令牌，而是让AuthService处理
            // 这样可以避免循环依赖和重复逻辑
            _ref.read(authStatusProvider.notifier).setUnauthenticated();
            handler.next(error);
            return;
          }

          // 处理其他常见错误
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            error = DioException(
              requestOptions: error.requestOptions,
              error: '连接超时，请检查网络',
              type: error.type,
              response: error.response,
            );
          } else if (error.type == DioExceptionType.connectionError) {
            error = DioException(
              requestOptions: error.requestOptions,
              error: '无法连接到服务器，请检查网络',
              type: error.type,
              response: error.response,
            );
          }

          handler.next(error);
        },
        onResponse: (response, handler) {
          // 成功响应，确认认证状态
          if (response.statusCode == 200) {
            _ref.read(authStatusProvider.notifier).setAuthenticated();
          }
          handler.next(response);
        },
      ),
    );
  }
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Ref _ref;

  // 使用统一配置的默认地址
  late String _baseUrl;

  // 设置服务器地址
  Future<void> setServerUrl(String url) async {
    var cleanUrl = url.trim();

    // 确保URL以http://或https://开头
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'http://$cleanUrl';
    }

    // 移除尾部斜杠
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }

    // 移除API版本路径
    final apiVersionPath = '/api/${ApiConfig.apiVersion}';
    if (cleanUrl.endsWith(apiVersionPath)) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - apiVersionPath.length);
    }

    _baseUrl = cleanUrl;

    if (kDebugMode) {
      print('🌐 设置服务器地址: $_baseUrl');
    }

    await _secureStorage.write(key: 'server_url', value: _baseUrl);
  }

  // 获取服务器地址
  Future<String> getServerUrl() async {
    final savedUrl = await _secureStorage.read(key: 'server_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _baseUrl = savedUrl;
    }

    // 确保baseUrl是一个有效的URL
    if (!_baseUrl.startsWith('http://') && !_baseUrl.startsWith('https://')) {
      _baseUrl = 'http://${_baseUrl}';
    }

    return _baseUrl;
  }

  // 获取已保存的服务器地址，如果不存在则返回null
  Future<String?> getSavedServerUrl() async {
    return _secureStorage.read(key: 'server_url');
  }

  String get baseUrl => _baseUrl;
  Dio get dio => _dio;
}

// Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  const secureStorage = FlutterSecureStorage();
  return ApiClient(secureStorage: secureStorage, ref: ref);
});
