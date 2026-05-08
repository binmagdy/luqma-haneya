import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luqma_haneya/app.dart';
import 'package:luqma_haneya/core/router/app_router.dart';

void main() {
  testWidgets('LuqmaHaneyaApp builds', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goRouterProvider.overrideWith(
            (ref) => GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, __) => const Scaffold(
                    body: Center(child: Text('test_root')),
                  ),
                ),
              ],
            ),
          ),
        ],
        child: const LuqmaHaneyaApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LuqmaHaneyaApp), findsOneWidget);
    expect(find.text('test_root'), findsOneWidget);
  });
}
