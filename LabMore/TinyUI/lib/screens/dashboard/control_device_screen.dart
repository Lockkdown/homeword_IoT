import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isOn = widget.device.isOn;
    _brightness = 50.0;
    
    // MqttService is now a singleton
    _mqttService.connect().then((_) {
      // Force current UI to match mqttService state if already connected
      if (mounted && _mqttService.isConnected) {
        setState(() {
          _isOn = _mqttService.relayState.value;
        });
      }
    });
    
    _mqttService.relayState.addListener(_onRelayStateChanged);
  }

  void _onRelayStateChanged() {
    if (mounted && _isOn != _mqttService.relayState.value) {
      setState(() {
        _isOn = _mqttService.relayState.value;
      });
      // Update local storage status with explicit boolean instead of toggle
      final deviceManager = DeviceManager();
      final updatedDevice = widget.device.copyWith(isOn: _isOn);
      deviceManager.updateDevice(updatedDevice);
    }
  }

  @override
  void dispose() {
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
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
          
          const Spacer(),
          
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
    debugPrint('[TOGGLE] Switch tapped => $value');
    debugPrint('[MQTT] connected=${_mqttService.isConnected}');
    setState(() {
      _isOn = value;
    });
    
    // Gửi lệnh MQTT
    final success = await _mqttService.publishRelayCommand(value);
    debugPrint('[TOGGLE] publishRelayCommand result=$success');

    if (!mounted) return;

    if (success) {
      // Thành công => update local memory
      final deviceManager = DeviceManager();
      deviceManager.toggleDevice(widget.device.id);
    } else {
      // Thất bại => Trả lại UI cũ và báo lỗi
      setState(() {
        _isOn = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send command. Check MQTT Connection.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: Colors.red,
        ),
      );
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
