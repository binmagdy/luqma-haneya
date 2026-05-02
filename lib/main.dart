// First-time setup: from this folder run `flutter create . --org com.luqma`
// to generate android/ and ios/, then `dart pub get` and `flutterfire configure`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/bootstrap.dart';

Future<void> main() async {
  await bootstrapApp();
  runApp(const ProviderScope(child: LuqmaHaneyaApp()));
}
