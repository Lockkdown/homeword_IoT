import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// REST API client — base URL via `--dart-define=API_BASE_URL=http://host:8080`
/// Mặc định cùng host LAN với mqtt default (thường là máy chạy Spring Boot + broker).
class ApiService {
  ApiService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final t = await _storage.read(key: _kTokenKey);
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          }
          return handler.next(options);
        },
      ),
    );
  }

  static final ApiService instance = ApiService._();
  factory ApiService() => instance;

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.58:8080',
  );

  static const _kTokenKey = 'tinyiot_jwt';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio _dio;

  Future<bool> get hasToken async {
    final t = await _storage.read(key: _kTokenKey);
    return t != null && t.isNotEmpty;
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _kTokenKey, value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _kTokenKey);
  }

  Future<String?> getToken() => _storage.read(key: _kTokenKey);

  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {'username': username, 'email': email, 'password': password},
    );
    final data = res.data!;
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'username': username, 'password': password},
    );
    final data = res.data!;
    return AuthResponse.fromJson(data);
  }

  Future<List<DeviceApiDto>> listDevices() async {
    final res = await _dio.get<List<dynamic>>('/api/devices');
    final list = res.data ?? [];
    return list
        .map((e) => DeviceApiDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DeviceApiDto> addDevice({
    required String deviceId,
    required String name,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/devices',
      data: {'deviceId': deviceId, 'name': name},
    );
    return DeviceApiDto.fromJson(res.data!);
  }

  Future<void> deleteDevice(int serverId) async {
    await _dio.delete<void>('/api/devices/$serverId');
  }

  Future<DeviceApiDto> controlDevice({
    required int serverId,
    required String command,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/api/devices/$serverId/control',
      data: {'command': command},
    );
    return DeviceApiDto.fromJson(res.data!);
  }

  Future<PzemReadingDto?> getPzemLatest(int serverId) async {
    final res = await _dio.get<Map<String, dynamic>?>(
      '/api/devices/$serverId/telemetry/pzem/latest',
      options: Options(
        validateStatus: (s) => s != null && (s == 200 || s == 204),
      ),
    );
    if (res.statusCode == 204 || res.data == null) return null;
    return PzemReadingDto.fromJson(res.data!);
  }

  Future<List<PzemReadingDto>> listPzem(int serverId, {int limit = 50}) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/devices/$serverId/telemetry/pzem',
      queryParameters: {'limit': limit},
    );
    final list = res.data ?? [];
    return list
        .map((e) => PzemReadingDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RelayHistoryDto>> relayHistory(int serverId, {int limit = 50}) async {
    final res = await _dio.get<List<dynamic>>(
      '/api/devices/$serverId/telemetry/relay-history',
      queryParameters: {'limit': limit},
    );
    final list = res.data ?? [];
    return list
        .map((e) => RelayHistoryDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Parses Dio errors into a short user message (đăng nhập, API chung).
  static String messageFromError(Object e) {
    if (e is! DioException) return e.toString();

    final res = e.response;
    if (res == null) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Hết thời gian chờ server. Kiểm tra mạng hoặc backend có chạy không.';
        case DioExceptionType.connectionError:
          return 'Không kết nối được server. Kiểm tra WiFi, firewall và '
              'API_BASE_URL (mặc định $baseUrl).';
        default:
          return e.message ?? 'Không kết nối được server. Kiểm tra mạng.';
      }
    }

    final data = res.data;
    final code = res.statusCode;
    if (data is Map) {
      final err = data['error'] ?? data['message'];
      if (err != null) return err.toString();
    } else if (data is String && data.trim().isNotEmpty) {
      final t = data.trim();
      return t.length > 160 ? '${t.substring(0, 160)}…' : t;
    }

    if (code == 401) return 'Email hoặc mật khẩu không đúng';
    if (code == 403) return 'Không có quyền truy cập';
    if (code != null) return 'Lỗi server (HTTP $code)';
    return e.message ?? 'Đăng nhập thất bại';
  }
}

class AuthResponse {
  final String token;
  final String username;
  final String email;

  AuthResponse({required this.token, required this.username, required this.email});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}

class DeviceApiDto {
  final int id;
  final String deviceId;
  final String name;
  final String status;
  final bool online;
  final bool receivesGlobalMqtt;
  final String? createdAt;
  final String? lastSeen;

  DeviceApiDto({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.status,
    required this.online,
    required this.receivesGlobalMqtt,
    this.createdAt,
    this.lastSeen,
  });

  factory DeviceApiDto.fromJson(Map<String, dynamic> json) {
    return DeviceApiDto(
      id: (json['id'] as num).toInt(),
      deviceId: json['deviceId'] as String,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'OFF',
      online: json['online'] as bool? ?? false,
      receivesGlobalMqtt: json['receivesGlobalMqtt'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      lastSeen: json['lastSeen'] as String?,
    );
  }
}

class PzemReadingDto {
  final double? voltage;
  final double? current;
  final double? power;
  final double? energy;
  final double? frequency;
  final double? powerFactor;
  final String? timestamp;

  PzemReadingDto({
    this.voltage,
    this.current,
    this.power,
    this.energy,
    this.frequency,
    this.powerFactor,
    this.timestamp,
  });

  factory PzemReadingDto.fromJson(Map<String, dynamic> json) {
    double? d(String k) => (json[k] as num?)?.toDouble();
    return PzemReadingDto(
      voltage: d('voltage'),
      current: d('current'),
      power: d('power'),
      energy: d('energy'),
      frequency: d('frequency'),
      powerFactor: d('powerFactor'),
      timestamp: json['timestamp'] as String?,
    );
  }
}

class RelayHistoryDto {
  final String command;
  final String source;
  final String? timestamp;

  RelayHistoryDto({required this.command, required this.source, this.timestamp});

  factory RelayHistoryDto.fromJson(Map<String, dynamic> json) {
    return RelayHistoryDto(
      command: json['command'] as String,
      source: json['source'] as String? ?? '',
      timestamp: json['timestamp'] as String?,
    );
  }
}
