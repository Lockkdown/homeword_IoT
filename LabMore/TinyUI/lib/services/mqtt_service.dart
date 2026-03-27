import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  static const String _broker = '192.168.1.58';
  static const int _port = 1883;
  static const String topicCommand = 'tiny/light/command';
  static const String topicBrightness = 'tiny/light/brightness';

  late final MqttServerClient _client;
  final ValueNotifier<bool> connectionStatus = ValueNotifier(false);

  MqttService() {
    _client = MqttServerClient.withPort(
      _broker,
      'tiny_ui_${DateTime.now().millisecondsSinceEpoch}',
      _port,
    );
    _client.setProtocolV311();
    _client.keepAlivePeriod = 60;
    _client.autoReconnect = true;
    _client.logging(on: false);
    _client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .startClean();
    _client.onConnected = () => connectionStatus.value = true;
    _client.onDisconnected = () => connectionStatus.value = false;
    _client.onAutoReconnected = () => connectionStatus.value = true;
  }

  bool get isConnected =>
      _client.connectionStatus?.state == MqttConnectionState.connected;

  Future<bool> connect() async {
    if (isConnected) {
      connectionStatus.value = true;
      return true;
    }

    try {
      final status = await _client.connect();
      final connected = status?.state == MqttConnectionState.connected;
      connectionStatus.value = connected;

      if (!connected) {
        _client.disconnect();
      }

      return connected;
    } catch (_) {
      connectionStatus.value = false;
      _client.disconnect();
      return false;
    }
  }

  Future<bool> publishCommand(bool isOn) =>
      _publish(topicCommand, isOn ? 'ON' : 'OFF');

  Future<bool> publishBrightness(double intensity) {
    final brightness = (intensity * 100).round().clamp(0, 100);
    return _publish(topicBrightness, brightness.toString());
  }

  // ── Relay – LED xanh module relay (GPIO 5)
  Future<bool> publishRelayCommand(bool isOn) =>
      _publish('tiny/relay/command', isOn ? 'ON' : 'OFF');

  // ── LED Bulb 5W AC (GPIO 5)
  Future<bool> publishLedCommand(bool isOn) =>
      _publish('tiny/led/command', isOn ? 'ON' : 'OFF');

  Future<bool> _publish(String topic, String payload) async {
    if (!isConnected && !await connect()) {
      connectionStatus.value = false;
      return false;
    }

    if (!isConnected) {
      connectionStatus.value = false;
      return false;
    }

    final builder = MqttClientPayloadBuilder()..addString(payload);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    return true;
  }

  void dispose() {
    _client.disconnect();
  }
}
