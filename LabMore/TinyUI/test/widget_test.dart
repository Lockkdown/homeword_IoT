// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_ui/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Smartify'), findsOneWidget);
  });
}
