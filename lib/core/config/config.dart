class AppConfig {
  AppConfig._();

  /// API 配置
  static const ApiConfig api = ApiConfig();

  /// 应用信息
  static const AppInfo app = AppInfo();

  /// 开发环境配置
  static const DevConfig dev = DevConfig();
}

/// API 相关配置
class ApiConfig {
  const ApiConfig();

  /// API 版本
  static const String apiVersion = 'v1';
  /// API 路径
  static const String authPath = '/auth';
  static const String photosPath = '/photos';
  static const String albumsPath = '/albums';
  static const String usersPath = '/users';
  /// 测试连接端点
  static const String pingEndpoint = '/ping';
  /// API 超时配置
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}

class AppInfo {
  const AppInfo();

  /// 应用名称
  static const String appName = 'GBox';

  /// 应用标语
  static const String appTagline = 'Your Personal Photo Cloud';

  /// 默认主题模式
  static const String defaultThemeMode = 'system'; // 'light', 'dark', 'system'
}

class DevConfig {
  const DevConfig();

  /// 是否启用调试日志
  static const bool enableDebugLogs = true;

  /// 常用的开发服务器地址示例
  static const List<ServerExample> serverExamples = [
    ServerExample('本地开发(HTTP)', 'http://localhost:15000'),
    ServerExample('本地开发(HTTPS)', 'https://localhost:15000'),
    ServerExample('Android 模拟器(HTTP)', 'http://10.0.2.2:15000'),
    ServerExample('Android 模拟器(HTTPS)', 'https://10.0.2.2:15000'),
    ServerExample('局域网示例(HTTP)', 'http://192.168.1.100:15000'),
    ServerExample('局域网示例(HTTPS)', 'https://192.168.1.100:15000'),
  ];
}

/// 服务器地址示例
class ServerExample {
  const ServerExample(this.label, this.url);
  final String label;
  final String url;
}
