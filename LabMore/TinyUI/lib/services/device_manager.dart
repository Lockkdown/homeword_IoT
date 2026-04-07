import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class DeviceModel {
  /// Hardware id (e.g. esp32_XXXX)
  final String id;
  /// Backend primary key — required for REST control/telemetry
  final int? serverId;
  final String name;
  final String type;
  final String? ssid;
  bool isOn;
  final DateTime addedAt;

  DeviceModel({
    required this.id,
    this.serverId,
    required this.name,
    required this.type,
    this.ssid,
    this.isOn = false,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serverId': serverId,
      'name': name,
      'type': type,
      'ssid': ssid,
      'isOn': isOn,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      serverId: (json['serverId'] as num?)?.toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      ssid: json['ssid'] as String?,
      isOn: json['isOn'] as bool? ?? false,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  DeviceModel copyWith({
    String? id,
    int? serverId,
    String? name,
    String? type,
    String? ssid,
    bool? isOn,
    DateTime? addedAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      name: name ?? this.name,
      type: type ?? this.type,
      ssid: ssid ?? this.ssid,
      isOn: isOn ?? this.isOn,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class DeviceManager extends ChangeNotifier {
  static final DeviceManager _instance = DeviceManager._internal();
  factory DeviceManager() => _instance;
  DeviceManager._internal();

  final ValueNotifier<List<DeviceModel>> devices = ValueNotifier([]);
  SharedPreferences? _prefs;
  final ApiService _api = ApiService();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await refreshFromBackendOrCache();
  }

  /// Prefer API when logged in; otherwise local cache.
  Future<void> refreshFromBackendOrCache() async {
    if (_prefs == null) await init();
    final loggedIn = await _api.hasToken;
    if (loggedIn) {
      try {
        final list = await _api.listDevices();
        final mapped = list.map(_fromDto).toList();
        devices.value = mapped;
        await _persistLocal();
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('[DeviceManager] API refresh failed: $e');
      }
    }
    await _loadFromPrefsOnly();
  }

  DeviceModel _fromDto(DeviceApiDto d) {
    final on = d.status.toUpperCase() == 'ON';
    return DeviceModel(
      id: d.deviceId,
      serverId: d.id,
      name: d.name,
      type: 'lamp',
      isOn: on,
      addedAt: DateTime.now(),
    );
  }

  Future<void> _loadFromPrefsOnly() async {
    final devicesJson = _prefs!.getStringList('devices') ?? [];
    final deviceList = devicesJson
        .map((json) => DeviceModel.fromJson(jsonDecode(json)))
        .toList();
    devices.value = deviceList;
    notifyListeners();
  }

  Future<void> _persistLocal() async {
    if (_prefs == null) await init();
    final devicesJson =
        devices.value.map((d) => jsonEncode(d.toJson())).toList();
    await _prefs!.setStringList('devices', devicesJson);
  }

  /// Add device locally + register on backend when token exists.
  Future<void> addDevice(DeviceModel device) async {
    if (_prefs == null) await init();
    DeviceModel toStore = device;

    if (await _api.hasToken) {
      try {
        final dto = await _api.addDevice(deviceId: device.id, name: device.name);
        toStore = device.copyWith(
          serverId: dto.id,
          isOn: dto.status.toUpperCase() == 'ON',
        );
      } catch (e) {
        debugPrint('[DeviceManager] addDevice API failed: $e');
      }
    }

    final updatedDevices = [...devices.value, toStore];
    devices.value = updatedDevices;
    await _persistLocal();
    notifyListeners();
  }

  Future<void> updateDevice(DeviceModel updatedDevice) async {
    if (_prefs == null) await init();
    final idx = devices.value.indexWhere((d) => d.id == updatedDevice.id);
    if (idx < 0) return;
    final cur = devices.value[idx];
    if (cur.isOn == updatedDevice.isOn &&
        cur.serverId == updatedDevice.serverId &&
        cur.name == updatedDevice.name &&
        cur.type == updatedDevice.type &&
        cur.ssid == updatedDevice.ssid) {
      return;
    }
    final updatedDevices = devices.value.map((device) {
      if (device.id == updatedDevice.id) {
        return updatedDevice;
      }
      return device;
    }).toList();
    devices.value = updatedDevices;
    await _persistLocal();
    notifyListeners();
  }

  Future<void> toggleDevice(String id) async {
    if (_prefs == null) await init();
    final updatedDevices = devices.value.map((device) {
      if (device.id == id) {
        return device.copyWith(isOn: !device.isOn);
      }
      return device;
    }).toList();
    devices.value = updatedDevices;
    await _persistLocal();
    notifyListeners();
  }

  Future<void> removeDevice(String id) async {
    if (_prefs == null) await init();
    DeviceModel? existing;
    for (final d in devices.value) {
      if (d.id == id) {
        existing = d;
        break;
      }
    }
    if (existing != null &&
        existing.serverId != null &&
        await _api.hasToken) {
      try {
        await _api.deleteDevice(existing.serverId!);
      } catch (e) {
        debugPrint('[DeviceManager] delete API failed: $e');
      }
    }
    final updatedDevices =
        devices.value.where((device) => device.id != id).toList();
    devices.value = updatedDevices;
    await _persistLocal();
    notifyListeners();
  }

  DeviceModel? getDeviceById(String id) {
    try {
      return devices.value.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  int get deviceCount => devices.value.length;

  Future<void> logoutClearLocal() async {
    devices.value = [];
    if (_prefs == null) await init();
    await _prefs!.remove('devices');
    notifyListeners();
  }
}
