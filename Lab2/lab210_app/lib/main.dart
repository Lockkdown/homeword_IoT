import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

const String _brokerHost = '10.98.121.184';
const int _brokerPort = 1883;
const String _ledTopic = '/topic/led/control';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT LED Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const LedControlPage(),
    );
  }
}

class LedControlPage extends StatefulWidget {
  const LedControlPage({super.key});

  @override
  State<LedControlPage> createState() => _LedControlPageState();
}

class _LedControlPageState extends State<LedControlPage> {
  late MqttServerClient _client;
  bool _connected = false;
  bool _ledOn = false;

  @override
  void initState() {
    super.initState();
    _connectMqtt();
  }

  Future<void> _connectMqtt() async {
    _client = MqttServerClient(_brokerHost, 'flutter_${DateTime.now().millisecondsSinceEpoch}');
    _client.port = _brokerPort;
    _client.keepAlivePeriod = 30;
    _client.autoReconnect = true;
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onAutoReconnected = _onConnected;

    final connMsg = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .startClean();
    _client.connectionMessage = connMsg;

    try {
      await _client.connect();
    } catch (_) {
      _client.disconnect();
    }
  }

  void _onConnected() {
    _client.subscribe(_ledTopic, MqttQos.atLeastOnce);
    _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      final msg = messages[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
      if (mounted) {
        setState(() {
          if (payload == '1') _ledOn = true;
          if (payload == '0') _ledOn = false;
        });
      }
    });
    if (mounted) setState(() => _connected = true);
  }

  void _onDisconnected() {
    if (mounted) setState(() => _connected = false);
  }

  void _toggle() {
    if (!_connected) return;
    final next = !_ledOn;
    final builder = MqttClientPayloadBuilder();
    builder.addString(next ? '1' : '0');
    _client.publishMessage(_ledTopic, MqttQos.atLeastOnce, builder.payload!, retain: true);
  }

  @override
  void dispose() {
    _client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'IoT LED Control',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _connected ? const Color(0xFF14532D) : const Color(0xFF3B1F1F),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _connected ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _connected ? 'Broker connected' : 'Connecting...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _connected ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF334155)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _ledOn ? const Color(0xFFFACC15) : const Color(0xFF334155),
                          boxShadow: _ledOn
                              ? [BoxShadow(color: const Color(0xFFFACC15).withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 5)]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _ledOn ? 'ON' : 'OFF',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _connected ? _toggle : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _ledOn ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                            elevation: 8,
                            shadowColor: _ledOn
                                ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                                : const Color(0xFF3B82F6).withValues(alpha: 0.4),
                          ),
                          child: Text(_ledOn ? 'Turn OFF' : 'Turn ON'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Topic: $_ledTopic',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
