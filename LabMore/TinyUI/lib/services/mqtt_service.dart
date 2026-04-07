import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class PowerMetrics extends ChangeNotifier {
  double _voltage = 0;
  double _current = 0;
  double _power = 0;
  double _energy = 0;
  double _frequency = 0;
  double _powerFactor = 0;
  DateTime _lastUpdate = DateTime.now();

  double get voltage => _voltage;
  double get current => _current;
  double get power => _power;
  double get energy => _energy;
  double get frequency => _frequency;
  double get powerFactor => _powerFactor;
  DateTime get lastUpdate => _lastUpdate;

  void update({
    double? voltage,
    double? current,
    double? power,
    double? energy,
    double? frequency,
    double? powerFactor,
  }) {
    if (voltage != null) _voltage = voltage;
    if (current != null) _current = current;
    if (power != null) _power = power;
    if (energy != null) _energy = energy;
    if (frequency != null) _frequency = frequency;
    if (powerFactor != null) _powerFactor = powerFactor;
    _lastUpdate = DateTime.now();
    notifyListeners();
  }
}

class MqttService {
  /// Broker host — `--dart-define=MQTT_HOST=192.168.x.x`
  static const String _broker = String.fromEnvironment(
    'MQTT_HOST',
    defaultValue: '192.168.1.58',
  );
  /// EMQX broker port 1883 (same broker as ESP32)
  static const int _port = int.fromEnvironment(
    'MQTT_PORT',
    defaultValue: 1883,
  );
  static const String topicCommand = 'tiny/light/command';
  static const String topicBrightness = 'tiny/light/brightness';

  // Power topics
  static const String topicPowerVoltage = 'tiny/power/voltage';
  static const String topicPowerCurrent = 'tiny/power/current';
  static const String topicPowerWatts = 'tiny/power/watts';
  static const String topicPowerEnergy = 'tiny/power/energy';
  static const String topicPowerFreq = 'tiny/power/frequency';
  static const String topicPowerPf = 'tiny/power/pf';

  // Relay topics
  static const String topicRelayCommand = 'tiny/relay/command';
  static const String topicRelayState = 'tiny/relay/state';

  late final MqttServerClient _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage?>>>? _updatesSub;
  final ValueNotifier<bool> connectionStatus = ValueNotifier(false);
  final ValueNotifier<bool> relayState = ValueNotifier(false);
  final ValueNotifier<PowerMetrics> powerMetrics = ValueNotifier(PowerMetrics());

  // Singleton pattern for MqttService
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  
  MqttService._internal() {
    _client = MqttServerClient.withPort(
      _broker,
      'tiny_ui_${DateTime.now().millisecondsSinceEpoch}',
      _port,
    );
    _client.setProtocolV311();
    _client.keepAlivePeriod = 60;
    // autoReconnect tắt khi khởi tạo; bật sau khi connect thành công
    // để tránh exception rò rỉ ra ngoài khi broker chưa sẵn sàng
    _client.autoReconnect = false;
    _client.logging(on: false);
    _client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .startClean();
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
  }

  void _onDisconnected() {
    connectionStatus.value = false;
    // Tự retry sau 5 giây nếu bị ngắt kết nối
    Future.delayed(const Duration(seconds: 5), () {
      if (!isConnected) connect();
    });
  }

  void _onConnected() {
    connectionStatus.value = true;
    _subscribeToTopics();
  }

  void _subscribeToTopics() {
    // Subscribe power topics
    _client.subscribe(topicPowerVoltage, MqttQos.atMostOnce);
    _client.subscribe(topicPowerCurrent, MqttQos.atMostOnce);
    _client.subscribe(topicPowerWatts, MqttQos.atMostOnce);
    _client.subscribe(topicPowerEnergy, MqttQos.atMostOnce);
    _client.subscribe(topicPowerFreq, MqttQos.atMostOnce);
    _client.subscribe(topicPowerPf, MqttQos.atMostOnce);

    // Subscribe relay state (retained)
    _client.subscribe(topicRelayState, MqttQos.atMostOnce);

    // Một listener duy nhất — mỗi lần reconnect tránh chồng listen
    _updatesSub?.cancel();
    _updatesSub = _client.updates!.listen(_onMessage);
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage?>> messages) {
    for (final msg in messages) {
      final topic = msg.topic;
      final payload = (msg.payload as MqttPublishMessage).payload.message;
      final value = String.fromCharCodes(payload);

      switch (topic) {
        case topicPowerVoltage:
          powerMetrics.value.update(voltage: double.tryParse(value) ?? 0);
          break;
        case topicPowerCurrent:
          powerMetrics.value.update(current: double.tryParse(value) ?? 0);
          break;
        case topicPowerWatts:
          powerMetrics.value.update(power: double.tryParse(value) ?? 0);
          break;
        case topicPowerEnergy:
          powerMetrics.value.update(energy: double.tryParse(value) ?? 0);
          break;
        case topicPowerFreq:
          powerMetrics.value.update(frequency: double.tryParse(value) ?? 0);
          break;
        case topicPowerPf:
          powerMetrics.value.update(powerFactor: double.tryParse(value) ?? 0);
          break;
        case topicRelayState:
          final on = value.trim().toUpperCase() == 'ON';
          if (relayState.value != on) {
            debugPrint('[MQTT RECEIVED] $topic => $value');
            relayState.value = on;
          }
          break;
      }
    }
  }

  bool get isConnected =>
      _client.connectionStatus?.state == MqttConnectionState.connected;

  Future<bool> connect() async {
    if (isConnected) {
      connectionStatus.value = true;
      return true;
    }

    try {
      debugPrint('[MQTT] Connecting to $_broker:$_port ...');
      final status = await _client.connect().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint('[MQTT] Connect timeout');
          return null;
        },
      );
      final connected =
          status?.state == MqttConnectionState.connected;
      connectionStatus.value = connected;
      debugPrint(
          '[MQTT] Connect result: ${status?.state} | returnCode: ${status?.returnCode}');

      if (!connected) {
        try { _client.disconnect(); } catch (_) {}
      }

      return connected;
    } catch (e) {
      // Swallow mọi lỗi MQTT — không cho phép exception này rò rỉ lên UI
      debugPrint('[MQTT] Connect error (suppressed): $e');
      connectionStatus.value = false;
      try { _client.disconnect(); } catch (_) {}
      return false;
    }
  }

  Future<bool> publishCommand(bool isOn) =>
      _publish(topicCommand, isOn ? 'ON' : 'OFF');

  Future<bool> publishBrightness(double intensity) {
    final brightness = (intensity * 100).round().clamp(0, 100);
    return _publish(topicBrightness, brightness.toString());
  }

  // ── Relay control
  Future<bool> publishRelayCommand(bool isOn) =>
      _publish(topicRelayCommand, isOn ? 'ON' : 'OFF');

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
    _client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    return true;
  }

  void dispose() {
    _updatesSub?.cancel();
    _updatesSub = null;
    _client.disconnect();
  }
}
