import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/app/presentation/widgets/app.dart';
import 'package:mobile/core/services/image_cache.dart';
import 'package:mobile/core/services/database.dart';
import 'package:mobile/core/providers/database.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  ImageCacheService.initialize();
  final isar = await DatabaseService.init();

  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(isar),
    ],
    child: const App(),
  ));
}
