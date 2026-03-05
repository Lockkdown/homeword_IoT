import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Tự động chọn base URL theo môi trường:
/// - Docker nginx (port 3000): "" → relative /api → nginx proxy → backend:8080
/// - flutter run web dev (port khác 3000): "http://localhost:8080"
/// - Android (WiFi): trỏ thẳng tới IP máy host trên mạng nội bộ
String get _resolvedBaseUrl {
  if (kIsWeb) {
    // Nếu đang serve từ Docker nginx port 3000 → dùng relative /api
    if (Uri.base.port == 3000) return '';
    // flutter run web dev (port khác 3000) → backend Docker expose ở 8080
    return 'http://localhost:8080';
  }
  // Android qua WiFi — máy host IP: 10.124.37.184
  return 'http://10.124.37.184:8080';
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Device Dashboard',
      home: const IoTDeviceDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class IoTDeviceDashboard extends StatefulWidget {
  const IoTDeviceDashboard({super.key});
  @override
  State<IoTDeviceDashboard> createState() => _IoTDeviceDashboardState();
}

class _IoTDeviceDashboardState extends State<IoTDeviceDashboard> {
  String get _baseUrl => _resolvedBaseUrl;
  List<Device> _devices = [];
  final _deviceNameController = TextEditingController();
  final _deviceTopicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  Future<void> fetchDevices() async {
    final response = await http.get(Uri.parse('$_baseUrl/devices'));
    if (response.statusCode == 200) {
      final List list = json.decode(response.body);
      setState(() {
        _devices = list
            .map((item) => Device.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> createDevice() async {
    if (_deviceNameController.text.isEmpty ||
        _deviceTopicController.text.isEmpty)
      return;
    final response = await http.post(
      Uri.parse('$_baseUrl/devices'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _deviceNameController.text,
        'topic': _deviceTopicController.text,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      _deviceNameController.clear();
      _deviceTopicController.clear();
      fetchDevices();
    }
  }

  Future<void> controlDevice(int id, String payload) async {
    if (payload.isEmpty) return;
    final response = await http.post(
      Uri.parse('$_baseUrl/devices/$id/control'),
      headers: {'Content-Type': 'text/plain'},
      body: payload,
    );
    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Lệnh đã gửi!')));
    }
  }

  void _showTelemetryDialog(int deviceId, String deviceName) {
    showDialog(
      context: context,
      builder: (context) => _TelemetryDialog(
        deviceId: deviceId,
        deviceName: deviceName,
        baseUrl: _baseUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '📡 IoT Device Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Danh sách thiết bị ──────────────────────────────────────
          const Text(
            '📋 Danh sách thiết bị',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._devices.map(
            (d) => _DeviceCard(
              device: d,
              baseUrl: _baseUrl,
              onSend: (payload) => controlDevice(d.id, payload),
              onViewData: () => _showTelemetryDialog(d.id, d.name),
            ),
          ),

          const SizedBox(height: 8),
          const Divider(thickness: 1),
          const SizedBox(height: 8),

          // ── Thêm thiết bị mới ────────────────────────────────────────
          const Text(
            '+ Thêm thiết bị mới',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _deviceNameController,
            decoration: InputDecoration(
              hintText: 'Tên thiết bị',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _deviceTopicController,
            decoration: InputDecoration(
              hintText: 'Topic MQTT',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: createDevice,
              icon: const Icon(Icons.add),
              label: const Text(
                'TẠO THIẾT BỊ',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Device Card ──────────────────────────────────────────────────────────────

class _DeviceCard extends StatefulWidget {
  final Device device;
  final String baseUrl;
  final void Function(String payload) onSend;
  final VoidCallback onViewData;

  const _DeviceCard({
    required this.device,
    required this.baseUrl,
    required this.onSend,
    required this.onViewData,
  });

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên + topic
            Text(
              widget.device.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              'MQTT Topic: ${widget.device.topic}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            // TextField payload
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Lệnh điều khiển',
                hintText: '{data:20}',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Hai nút cùng hàng, căn phải
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => widget.onSend(_controller.text),
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text(
                    'GỬI LỆNH',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: widget.onViewData,
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text(
                    'XEM DỮ LIỆU',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Device {
  final int id;
  final String name;
  final String topic;
  Device({required this.id, required this.name, required this.topic});
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(id: json['id'], name: json['name'], topic: json['topic']);
  }
}

class Telemetry {
  final DateTime timestamp;
  final String value;
  Telemetry({required this.timestamp, required this.value});
  factory Telemetry.fromJson(Map<String, dynamic> json) {
    return Telemetry(
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      value: json['value'] ?? json['payload'] ?? '',
    );
  }
}

// ─── Telemetry Dialog ─────────────────────────────────────────────────────────

class _TelemetryDialog extends StatefulWidget {
  final int deviceId;
  final String deviceName;
  final String baseUrl;
  const _TelemetryDialog({
    required this.deviceId,
    required this.deviceName,
    required this.baseUrl,
  });
  @override
  State<_TelemetryDialog> createState() => _TelemetryDialogState();
}

class _TelemetryDialogState extends State<_TelemetryDialog> {
  List<Telemetry> _data = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http.get(
        Uri.parse('${widget.baseUrl}/telemetry/${widget.deviceId}'),
      );
      if (res.statusCode == 200) {
        final List list = json.decode(res.body);
        setState(() {
          _data = list
              .map((e) => Telemetry.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      } else {
        setState(() => _error = 'Lỗi server: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Không thể kết nối backend.');
    } finally {
      setState(() => _loading = false);
    }
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year;
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    return '$dd/$mm/$yy $hh:$min:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
      title: Row(
        children: [
          const Icon(Icons.visibility, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Telemetry — ${widget.deviceName}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (!_loading && _error == null)
            Chip(
              label: Text(
                '${_data.length} bản ghi',
                style: const TextStyle(fontSize: 11),
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              backgroundColor: _data.isEmpty
                  ? Colors.grey[200]
                  : Colors.blue[100],
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _fetch,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            : _error != null
            ? ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: Text(_error!),
              )
            : _data.isEmpty
            ? const ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue),
                title: Text('Chưa có dữ liệu telemetry.'),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    headingRowColor: WidgetStateProperty.all(
                      Colors.blue.shade50,
                    ),
                    columns: const [
                      DataColumn(label: Text('#')),
                      DataColumn(label: Text('Giá trị')),
                      DataColumn(label: Text('Thời gian')),
                    ],
                    rows: _data.asMap().entries.map((entry) {
                      final i = entry.key;
                      final t = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(
                            Text(
                              t.value,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _formatDate(t.timestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
