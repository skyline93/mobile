import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobile/features/auth/data/models/user.model.dart';

class DatabaseService {
  static Isar? _isar;

  static Future<Isar> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      // 创建 Isar 实例并保存到静态变量
      _isar = await Isar.open(
        [
          UserSchema,
        ],
        directory: dir.path,
        name: 'gbox_mobile',
      );

      return _isar!;
    } catch (e) {
      rethrow;
    }
  }

  static Isar get instance {
    if (_isar == null) {
      throw Exception(
        'Database not initialized. Call DatabaseService.init() first.',);
    }
    return _isar!;
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  static Future<void> clear() async {
    await _isar?.writeTxn(() async {
      await _isar!.clear();
    });
  }
}
