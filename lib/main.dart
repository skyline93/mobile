import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/app/presentation/widgets/app.dart';

void main() async{
  runApp(ProviderScope(
    child: const App(),
  ));
}
