import 'package:flutter/foundation.dart';
import 'package:mobile/features/auth/data/models/login.dart';
import 'package:mobile/features/auth/data/models/register.dart';
import 'package:mobile/features/auth/services/auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 认证状态
class AuthState {
  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.currentUser,
    this.error,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final UserInfo? currentUser;
  final String? error;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserInfo? currentUser,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      error: error,
    );
  }
}

// 认证状态管理器
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(AuthState()) {
    // 初始化时检查登录状态
    checkAuthStatus();
  }

  final AuthService _authService;

  // 检查认证状态
  Future<void> checkAuthStatus() async {
    if (kDebugMode) {
      print('🔐 检查认证状态...');
    }

    state = state.copyWith(isLoading: true);

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        if (kDebugMode) {
          print('🔐 发现本地令牌，尝试获取用户信息...');
        }

        // 先加载保存的用户信息，提供即时反馈
        final savedUser = await _authService.getSavedUserInfo();
        if (savedUser != null) {
          state = state.copyWith(
            isAuthenticated: true,
            currentUser: savedUser,
            isLoading: false,
          );
        }

        // 尝试获取最新的用户信息
        try {
          final latestUser = await _authService.getCurrentUser();
          if (latestUser != null) {
            if (kDebugMode) {
              print('✅ 成功获取最新用户信息');
            }
            state = state.copyWith(
              isAuthenticated: true,
              currentUser: latestUser,
              isLoading: false,
            );
          } else {
            // 如果获取用户信息失败，尝试刷新令牌
            if (kDebugMode) {
              print('⚠️ 获取用户信息失败，尝试刷新令牌...');
            }
            final refreshSuccess = await _authService.refreshToken();
            if (refreshSuccess) {
              // 刷新成功，再次尝试获取用户信息
              if (kDebugMode) {
                print('✅ 令牌刷新成功，重新获取用户信息');
              }
              final refreshedUser = await _authService.getCurrentUser();
              if (refreshedUser != null) {
                state = state.copyWith(
                  isAuthenticated: true,
                  currentUser: refreshedUser,
                  isLoading: false,
                );
                return;
              }
            }

            // 如果刷新失败或获取用户信息仍然失败，则认为未认证
            if (kDebugMode) {
              print('❌ 认证失败，需要重新登录');
            }
            await _authService.logout(); // 清除无效令牌
            state = state.copyWith(
              isAuthenticated: false,
              currentUser: null,
              isLoading: false,
            );
          }
        } catch (e) {
          // 如果获取最新用户信息失败，但有本地缓存的用户信息，仍然保持已认证状态
          // 这样可以避免因为临时网络问题导致用户被强制登出
          if (savedUser != null && state.isAuthenticated) {
            if (kDebugMode) {
              print('⚠️ 获取最新用户信息失败，但使用缓存信息保持已登录状态: $e');
            }
            state = state.copyWith(isLoading: false);
          } else {
            // 如果没有缓存信息，则认为未认证
            if (kDebugMode) {
              print('❌ 认证失败，需要重新登录: $e');
            }
            await _authService.logout();
            state = state.copyWith(
              isAuthenticated: false,
              currentUser: null,
              isLoading: false,
              error: e.toString(),
            );
          }
        }
      } else {
        if (kDebugMode) {
          print('🔐 未找到有效令牌，需要登录');
        }
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 检查认证状态时出错: $e');
      }
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 刷新用户信息
  Future<void> refreshUser() async {
    await checkAuthStatus();
  }

  // 登录
  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final request = LoginRequest(username: username, password: password);

      await _authService.login(request);

      // 登录成功后获取用户信息
      final userInfo = await _authService.getCurrentUser();

      state = state.copyWith(
        isAuthenticated: true,
        currentUser: userInfo,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // 登出
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();
      state = AuthState(); // 重置状态
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // 注册
  Future<bool> register(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = RegisterRequest(username: username, password: password);

      await _authService.register(request);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
