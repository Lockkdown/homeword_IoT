import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';
import 'package:permission_handler/permission_handler.dart';

class ESPProvisioningService {
  static const String _devicePrefix = "PROV_";
  static const String _popKey = "abcd1234";

  final _plugin = FlutterEspBleProv();

  final ValueNotifier<ProvisioningState> state =
      ValueNotifier(ProvisioningState.idle);
  final ValueNotifier<String> statusText =
      ValueNotifier("Ready to connect");

  /// Request permissions for BLE on Android 12+
  Future<bool> requestBlePermissions() async {
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location, // BẮT BUỘC cho native BLE scan
        Permission.locationWhenInUse,
      ].request();

      final locService = await Permission.location.serviceStatus;
      if (!locService.isEnabled) {
        statusText.value = "Please turn on GPS/Location services for BLE scan";
        return false;
      }

      final scan = statuses[Permission.bluetoothScan] == PermissionStatus.granted;
      final loc = statuses[Permission.location] == PermissionStatus.granted ||
          statuses[Permission.locationWhenInUse] == PermissionStatus.granted;

      if (!scan && !loc) {
        statusText.value = "Permissions missing";
        return false;
      }
    }
    return true;
  }

  /// Scan for WiFi networks *using the ESP32* instead of the phone
  Future<List<String>> getWifiNetworksFromDevice() async {
    try {
      final hasPerm = await requestBlePermissions();
      if (!hasPerm) {
        throw Exception("Bluetooth permission denied");
      }

      state.value = ProvisioningState.scanning;
      statusText.value = "Connecting to ESP32 to fetch WiFi list...";

      final devices = await _plugin.scanBleDevices(_devicePrefix);
      if (devices.isEmpty) {
        throw Exception("ESP32 device not found. Ensure it is advertising.");
      }

      final deviceName = devices.first;
      statusText.value = "Fetching WiFi networks from $deviceName...";

      // Call the ESP32 to scan its local environment
      final networks = await _plugin.scanWifiNetworks(deviceName, _popKey);
      
      state.value = ProvisioningState.idle;
      return networks;
    } catch (e) {
      state.value = ProvisioningState.failed;
      statusText.value = "Error fetching WiFi: $e";
      return [];
    }
  }

  Future<bool> startProvisioning({
    required String ssid,
    required String password,
  }) async {
    try {
      final hasPerm = await requestBlePermissions();
      if (!hasPerm) {
        state.value = ProvisioningState.failed;
        statusText.value =
            "Bluetooth permission denied. Please enable in Settings.";
        return false;
      }

      // Step 1: Scan for ESP32 BLE device
      state.value = ProvisioningState.scanning;
      statusText.value = "Scanning for ESP32 device...";

      final devices = await _plugin.scanBleDevices(_devicePrefix);

      if (devices.isEmpty) {
        state.value = ProvisioningState.failed;
        statusText.value =
            "No ESP32 device found. Make sure it is powered on and in provisioning mode.";
        return false;
      }

      final deviceName = devices.first;

      // Step 2: Send WiFi credentials using Espressif's protobuf protocol
      state.value = ProvisioningState.sending;
      statusText.value = "Sending WiFi credentials via BLE...";

      final success = await _plugin.provisionWifi(
        deviceName,
        _popKey,
        ssid,
        password,
      );

      if (success != true) {
        state.value = ProvisioningState.failed;
        statusText.value =
            "Provisioning failed. Check WiFi password and PoP key.";
        return false;
      }

      state.value = ProvisioningState.connected;
      statusText.value =
          "Provisioning successful! ESP32 is connecting to WiFi...";
      return true;
    } catch (e) {
      state.value = ProvisioningState.failed;
      statusText.value = "Error: $e";
      return false;
    }
  }

  void dispose() {
    state.dispose();
    statusText.dispose();
  }
}

enum ProvisioningState { idle, scanning, connecting, sending, connected, failed }
