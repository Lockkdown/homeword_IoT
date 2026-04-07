// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:tiny_ui/main.dart';
import 'package:tiny_ui/services/mqtt_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final mqttService = MqttService();
    await tester.pumpWidget(TinyUIApp(mqttService: mqttService));
    expect(find.text('TinyFlashBang'), findsOneWidget);
  });
}
