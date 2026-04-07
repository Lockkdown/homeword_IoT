import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/mqtt_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize MQTT service
  final mqttService = MqttService();
  mqttService.connect();
  
  runApp(TinyUIApp(mqttService: mqttService));
}

class TinyUIApp extends StatelessWidget {
  final MqttService mqttService;

  const TinyUIApp({super.key, required this.mqttService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinyUI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF324539),
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(mqttService: mqttService),
    );
  }
}
