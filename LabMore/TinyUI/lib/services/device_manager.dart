import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceModel {
  final String id;
  final String name;
  final String type;
  final String? ssid;
  bool isOn;
  final DateTime addedAt;

  DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    this.ssid,
    this.isOn = false,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'ssid': ssid,
      'isOn': isOn,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      ssid: json['ssid'],
      isOn: json['isOn'] ?? false,
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  DeviceModel copyWith({
    String? id,
    String? name,
    String? type,
    String? ssid,
    bool? isOn,
    DateTime? addedAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
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

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await loadDevices();
  }

  Future<void> loadDevices() async {
    if (_prefs == null) await init();
    
    final devicesJson = _prefs!.getStringList('devices') ?? [];
    final deviceList = devicesJson
        .map((json) => DeviceModel.fromJson(jsonDecode(json)))
        .toList();
    
    devices.value = deviceList;
    notifyListeners();
  }

  Future<void> addDevice(DeviceModel device) async {
    if (_prefs == null) await init();
    
    final updatedDevices = [...devices.value, device];
    devices.value = updatedDevices;
    
    final devicesJson = updatedDevices.map((d) => jsonEncode(d.toJson())).toList();
    await _prefs!.setStringList('devices', devicesJson);
    
    notifyListeners();
  }

  Future<void> updateDevice(DeviceModel updatedDevice) async {
    if (_prefs == null) await init();
    
    final updatedDevices = devices.value.map((device) {
      if (device.id == updatedDevice.id) {
        return updatedDevice;
      }
      return device;
    }).toList();
    
    devices.value = updatedDevices;
    
    final devicesJson = updatedDevices.map((d) => jsonEncode(d.toJson())).toList();
    await _prefs!.setStringList('devices', devicesJson);
    
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
    
    final devicesJson = updatedDevices.map((d) => jsonEncode(d.toJson())).toList();
    await _prefs!.setStringList('devices', devicesJson);
    
    notifyListeners();
  }

  Future<void> removeDevice(String id) async {
    if (_prefs == null) await init();
    
    final updatedDevices = devices.value.where((device) => device.id != id).toList();
    devices.value = updatedDevices;
    
    final devicesJson = updatedDevices.map((d) => jsonEncode(d.toJson())).toList();
    await _prefs!.setStringList('devices', devicesJson);
    
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
}
