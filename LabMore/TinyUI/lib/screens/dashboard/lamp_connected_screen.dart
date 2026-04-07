import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/device_manager.dart';
import 'control_device_screen.dart';

const Color _primaryBlue = Color(0xFF3B5BFA);
const Color _textDark = Color(0xFF1F2937);
const Color _textGrey = Color(0xFF6B7280);

class LampConnectedScreen extends StatefulWidget {
  final String? deviceId;
  final String? deviceName;
  final String? ssid;
  
  const LampConnectedScreen({
    super.key,
    this.deviceId,
    this.deviceName,
    this.ssid,
  });

  @override
  State<LampConnectedScreen> createState() => _LampConnectedScreenState();
}

class _LampConnectedScreenState extends State<LampConnectedScreen> {
  DeviceModel? _savedDevice;

  @override
  void initState() {
    super.initState();
    // Tự động lưu thiết bị ngay khi vào màn hình thành công
    _autoSaveDevice();
  }

  Future<void> _autoSaveDevice() async {
    if (widget.deviceId != null) {
      final deviceManager = DeviceManager();
      _savedDevice = DeviceModel(
        id: widget.deviceId!,
        name: widget.deviceName ?? 'Smart Lamp',
        type: 'lamp',
        ssid: widget.ssid,
      );
      await deviceManager.addDevice(_savedDevice!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Checkmark Icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: _primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 48),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Connected!',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'You have connected to Smart Lamp.',
                      style: GoogleFonts.inter(fontSize: 16, color: _textGrey),
                    ),
                    const SizedBox(height: 48),

                    // Main Product Image
                    Center(
                      child: Image.asset(
                        'assets/images/smart_lamp.jpg',
                        width: 240,
                        height: 320,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),

            // Bottom Buttons (Luôn cố định ở dưới)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF3FE),
                          foregroundColor: _primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Go to Homepage',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_savedDevice != null) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => ControlDeviceScreen(device: _savedDevice!),
                              ),
                              (route) => route.isFirst,
                            );
                          } else {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Control',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
