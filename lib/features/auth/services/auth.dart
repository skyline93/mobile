import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/core/services/api_client.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile/features/auth/data/models/login.dart';
import 'package:mobile/features/auth/data/models/register.dart';

class AuthService {
  AuthService({
    required ApiClient apiClient,
    required FlutterSecureStorage secureStorage,
  }) : _apiClient = apiClient,
       _secureStorage = secureStorage;
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  // 登录
  Future<TokenPair> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/token',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        // 解析API响应
        final apiResponse = ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => TokenPair.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.code == 0 && apiResponse.data != null) {
          final tokenPair = apiResponse.data!;

          // 保存tokens
          await _secureStorage.write(
            key: 'access_token',
            value: tokenPair.accessToken,
          );
          await _secureStorage.write(
            key: 'refresh_token',
            value: tokenPair.refreshToken,
          );

          // 登录成功后立即获取用户信息
          await getCurrentUser();

          return tokenPair;
        } else {
          throw Exception(apiResponse.message);
        }
      } else {
        throw Exception('登录失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('用户名或密码错误');
      } else if (e.response?.statusCode == 400) {
        final message = e.response?.data['message'] ?? '请求参数错误';
        throw Exception(message);
      } else {
        throw Exception('网络错误: ${e.message}');
      }
    } catch (e) {
      throw Exception('登录失败: $e');
    }
  }

  // 刷新令牌
  Future<bool> refreshToken() async {
    try {
      if (kDebugMode) {
        print('🔄 尝试刷新令牌...');
      }

      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) {
        if (kDebugMode) {
          print('❌ 没有找到刷新令牌');
        }
        return false;
      }

      // 获取服务器地址
      final baseUrl = await _apiClient.getServerUrl();
      final apiVersion = 'v1'; // 从配置中获取或硬编码

      // 构建完整的刷新令牌URL
      final refreshUrl = '$baseUrl/api/$apiVersion/auth/refresh';

      if (kDebugMode) {
        print('🔄 刷新令牌URL: $refreshUrl');
      }

      // 使用原始dio对象发送请求，避免被拦截器处理
      final response = await Dio().post<Map<String, dynamic>>(
        refreshUrl,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null &&
            responseData['code'] == 0 &&
            responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          final newAccessToken = data['access_token'] as String?;
          final newRefreshToken = data['refresh_token'] as String?;

          if (newAccessToken != null && newRefreshToken != null) {
            // 保存新令牌
            await _secureStorage.write(
              key: 'access_token',
              value: newAccessToken,
            );
            await _secureStorage.write(
              key: 'refresh_token',
              value: newRefreshToken,
            );

            if (kDebugMode) {
              print('✅ 令牌刷新成功');
            }
            return true;
          }
        }
      }

      if (kDebugMode) {
        print('❌ 令牌刷新失败: ${response.statusCode} ${response.data}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 令牌刷新出错: $e');
      }
      return false;
    }
  }

  // 注册
  Future<void> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final apiResponse = response.data!;
        if (apiResponse['code'] == 0) {
          // Registration successful
          return;
        } else {
          throw Exception(apiResponse['message'] ?? '注册失败');
        }
      } else {
        throw Exception('注册失败: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 500) {
        final message = e.response?.data?['message'] ?? '用户名已存在或格式错误';
        throw Exception(message);
      } else {
        throw Exception('网络错误: ${e.message}');
      }
    } catch (e) {
      throw Exception('注册失败: $e');
    }
  }

  // 登出
  Future<void> logout() async {
    // 只清除与用户会话相关的tokens和用户信息，保留服务器地址
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _secureStorage.delete(key: 'user_id');
    await _secureStorage.delete(key: 'username');
    await _secureStorage.delete(key: 'email');
    await _secureStorage.delete(key: 'role');
  }

  // 获取当前用户信息
  Future<UserInfo?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token == null) return null;

      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/auth/userinfo',
      );

      if (response.statusCode == 200) {
        final apiResponse = response.data!;
        if (apiResponse['code'] == 0 && apiResponse['data'] != null) {
          final userData = apiResponse['data'];
          // 后端返回的是包含 user 和 roles 的对象
          final user = userData['user'] as Map<String, dynamic>;

          // 转换角色编码为可读名称
          final roleCode = (user['role'] ?? 0) as int;
          final roleName = _getRoleName(roleCode);

          final userInfo = UserInfo(
            id: (user['id'] ?? 0) as int,
            username: (user['username'] ?? '') as String,
            email: (user['email'] ?? '') as String,
            role: roleName,
            createdAt: user['created_at'] != null
                ? DateTime.parse(user['created_at'] as String)
                : DateTime.now(),
          );

          await _saveUserInfo(userInfo);
          return userInfo;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('获取用户信息失败: $e');
      }
      return null;
    }
  }

  // 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'access_token');
    return token != null;
  }

  // 保存用户信息
  Future<void> _saveUserInfo(UserInfo userInfo) async {
    await _secureStorage.write(key: 'user_id', value: userInfo.id.toString());
    await _secureStorage.write(key: 'username', value: userInfo.username);
    await _secureStorage.write(key: 'email', value: userInfo.email);
    await _secureStorage.write(key: 'role', value: userInfo.role);
  }

  // 获取保存的用户信息
  Future<UserInfo?> getSavedUserInfo() async {
    final userId = await _secureStorage.read(key: 'user_id');
    final username = await _secureStorage.read(key: 'username');
    final email = await _secureStorage.read(key: 'email');
    final role = await _secureStorage.read(key: 'role');

    if (userId != null && username != null) {
      return UserInfo(
        id: int.parse(userId),
        username: username,
        email: email ?? '',
        role: role ?? '',
        createdAt: DateTime.now(),
      );
    }
    return null;
  }

  // 角色编码转换
  String _getRoleName(int roleCode) {
    switch (roleCode) {
      case 0:
        return 'guest';
      case 1:
        return 'user';
      case 2:
        return 'admin';
      default:
        return 'user';
    }
  }
}

// Provider
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  const secureStorage = FlutterSecureStorage();
  return AuthService(apiClient: apiClient, secureStorage: secureStorage);
});
