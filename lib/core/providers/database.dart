import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

// 数据库实例 Provider
final databaseProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Database provider must be overridden');
});
