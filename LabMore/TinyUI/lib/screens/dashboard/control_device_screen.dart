import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/api_service.dart';
import '../../services/device_manager.dart';
import '../../services/mqtt_service.dart';

const Color _primaryBlue = Color(0xFF3B5BFA);
const Color _textDark = Color(0xFF1F2937);
const Color _textGrey = Color(0xFF6B7280);

class ControlDeviceScreen extends StatefulWidget {
  final DeviceModel device;

  const ControlDeviceScreen({
    super.key,
    required this.device,
  });

  @override
  State<ControlDeviceScreen> createState() => _ControlDeviceScreenState();
}

class _ControlDeviceScreenState extends State<ControlDeviceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _brightness = 50.0;
  bool _isOn = false;
  final MqttService _mqttService = MqttService();
  final ApiService _api = ApiService();

  Timer? _telemetryTimer;
  Timer? _relayPersistDebounce;
  PzemReadingDto? _pzem;
  List<RelayHistoryDto> _relayHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isOn = widget.device.isOn;
    _brightness = 50.0;

    // Lắng nghe relay state từ MQTT (công tắc vật lý ESP32 → UI)
    _mqttService.relayState.addListener(_onRelayStateChanged);

    // Kết nối MQTT và đồng bộ trạng thái ngay khi vào màn hình
    _connectAndSync();

    if (widget.device.serverId != null) {
      _loadTelemetry();
      _telemetryTimer =
          Timer.periodic(const Duration(seconds: 5), (_) => _loadTelemetry());
    }
  }

  Future<void> _connectAndSync() async {
    await _mqttService.connect();
    if (!mounted) return;
    // Đồng bộ trạng thái hiện tại từ MQTT cache
    setState(() {
      _isOn = _mqttService.relayState.value;
    });
    // Load trạng thái mới nhất từ API nếu có serverId
    if (widget.device.serverId != null) {
      try {
        final h = await _api.relayHistory(widget.device.serverId!, limit: 1);
        if (!mounted) return;
        if (h.isNotEmpty) {
          setState(() {
            _isOn = h.first.command == 'ON';
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _loadTelemetry() async {
    final sid = widget.device.serverId;
    if (sid == null) return;
    try {
      final p = await _api.getPzemLatest(sid);
      final h = await _api.relayHistory(sid, limit: 15);
      if (!mounted) return;
      setState(() {
        _pzem = p;
        _relayHistory = h;
      });
    } catch (_) {
      /* ignore */
    }
  }

  /// Gọi khi ESP32 publish tiny/relay/state (công tắc vật lý hoặc phản hồi lệnh).
  /// Không gọi _loadTelemetry ở đây — mỗi lần ON/OFF là 2 HTTP; timer 5s đủ cho PZEM/history.
  void _onRelayStateChanged() {
    if (!mounted) return;
    final newState = _mqttService.relayState.value;
    if (_isOn != newState) {
      setState(() => _isOn = newState);
      _relayPersistDebounce?.cancel();
      _relayPersistDebounce = Timer(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        DeviceManager().updateDevice(widget.device.copyWith(isOn: newState));
      });
    }
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _relayPersistDebounce?.cancel();
    _mqttService.relayState.removeListener(_onRelayStateChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Device', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove ${widget.device.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final deviceManager = DeviceManager();
              await deviceManager.removeDevice(widget.device.id);
              if (mounted) {
                Navigator.of(ctx).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to dashboard
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _textDark, size: 24),
        ),
        title: Text(
          'Control Device',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
            onPressed: () => _showDeleteConfirmation(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: _textDark, size: 24),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Device Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isOn ? const Color(0xFFFFB800) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline,
                        color: _isOn ? Colors.white : _textGrey,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.device.name,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Living Room',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: _textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isOn,
                      onChanged: _toggleDevice,
                      activeThumbColor: _primaryBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: _primaryBlue,
              unselectedLabelColor: _textGrey,
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'White'),
                Tab(text: 'Color'),
                Tab(text: 'Scene'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWhiteTab(),
                _buildColorTab(),
                _buildSceneTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.device.serverId != null) ...[
            Text(
              'PZEM / Lịch sử relay',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 12),
            if (_pzem != null)
              Card(
                elevation: 0,
                color: const Color(0xFFF5F5F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _metricRow('U', '${_pzem!.voltage?.toStringAsFixed(1) ?? "—"} V'),
                      _metricRow('I', '${_pzem!.current?.toStringAsFixed(3) ?? "—"} A'),
                      _metricRow('P', '${_pzem!.power?.toStringAsFixed(1) ?? "—"} W'),
                      _metricRow('E', '${_pzem!.energy?.toStringAsFixed(3) ?? "—"} kWh'),
                      _metricRow('Hz', '${_pzem!.frequency?.toStringAsFixed(1) ?? "—"} Hz'),
                      _metricRow('PF', _pzem!.powerFactor?.toStringAsFixed(2) ?? '—'),
                    ],
                  ),
                ),
              )
            else
              Text(
                'Chưa có dữ liệu PZEM (đợi thiết bị gửi MQTT).',
                style: GoogleFonts.inter(fontSize: 14, color: _textGrey),
              ),
            const SizedBox(height: 16),
            if (_relayHistory.isNotEmpty) ...[
              Text(
                'Relay gần đây',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textGrey,
                ),
              ),
              const SizedBox(height: 8),
              ..._relayHistory.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${r.command} · ${r.source}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      Text(
                        r.timestamp ?? '',
                        style: GoogleFonts.inter(fontSize: 11, color: _textGrey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
          // Color Temperature Arc (Decorative)
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background arc
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        const Color(0xFFFFE4B5), // Warm
                        const Color(0xFFFFFFFF), // Cool
                        const Color(0xFFE0F2FE), // Very cool
                        const Color(0xFFFFE4B5), // Warm again to complete circle
                      ],
                      stops: const [0.0, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
                // Inner circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/smart_lamp.jpg',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Brightness Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Brightness',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              Text(
                '${_brightness.round()}%',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Brightness Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: _primaryBlue,
              inactiveTrackColor: const Color(0xFFE5E7EB),
              thumbColor: _primaryBlue,
            ),
            child: Slider(
              value: _brightness,
              min: 0,
              max: 100,
              onChanged: _updateBrightness,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Schedule Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Show schedule dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Schedule feature coming soon',
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Schedule Automatic ON/OFF',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _textGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTab() {
    return Center(
      child: Text(
        'Color control coming soon',
        style: GoogleFonts.inter(
          fontSize: 16,
          color: _textGrey,
        ),
      ),
    );
  }

  Widget _buildSceneTab() {
    return Center(
      child: Text(
        'Scene control coming soon',
        style: GoogleFonts.inter(
          fontSize: 16,
          color: _textGrey,
        ),
      ),
    );
  }

  void _toggleDevice(bool value) async {
    // Cập nhật UI ngay lập tức (optimistic update)
    setState(() => _isOn = value);

    final cmd = value ? 'ON' : 'OFF';

    if (widget.device.serverId != null) {
      // Gọi API → backend publish MQTT → ESP32 nhận → ESP32 publish relay/state
      // → Flutter MQTT listener tự cập nhật UI qua _onRelayStateChanged
      try {
        await _api.controlDevice(serverId: widget.device.serverId!, command: cmd);
        await DeviceManager().updateDevice(widget.device.copyWith(isOn: value));
        // Bỏ await _loadTelemetry — giảm cảm giác lag; timer định kỳ vẫn cập nhật
      } catch (e) {
        if (!mounted) return;
        // Rollback UI nếu API lỗi
        setState(() => _isOn = !value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiService.messageFromError(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Không có serverId: publish MQTT trực tiếp
      final ok = await _mqttService.publishRelayCommand(value);
      if (!ok && mounted) {
        setState(() => _isOn = !value);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không gửi được lệnh MQTT. Kiểm tra kết nối.',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (ok) {
        await DeviceManager().updateDevice(widget.device.copyWith(isOn: value));
      }
    }
  }

  void _updateBrightness(double value) {
    setState(() {
      _brightness = value;
    });
    
    // Send MQTT brightness command
    _mqttService.publishBrightness(value / 100.0);
  }
}
