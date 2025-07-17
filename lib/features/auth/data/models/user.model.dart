import 'package:isar/isar.dart';

part 'user.model.g.dart';

@Collection()
class User {
  Id id = Isar.autoIncrement;

  late String email;
  late String name;
  String? avatarUrl;
  late String serverUrl;
  late String accessToken;
  String? refreshToken;

  @Index()
  late bool isLoggedIn;

  DateTime? lastLoginAt;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
