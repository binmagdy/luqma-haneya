import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luqma_haneya/app.dart';

void main() {
  testWidgets('LuqmaHaneyaApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LuqmaHaneyaApp()));
    await tester.pump();
    expect(find.byType(LuqmaHaneyaApp), findsOneWidget);
  });
}
