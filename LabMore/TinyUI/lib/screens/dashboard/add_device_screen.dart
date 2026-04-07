import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import 'connect_to_device_screen.dart';
import 'lamp_connect_screen.dart';
import 'scan_device_qr_screen.dart';
import 'foster_connect_screen.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);

  bool _isNearbyTab = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'Popular',
    'Lightning',
    'Camera',
    'Electrical',
  ];

  final List<Map<String, String>> _manualDevices = [
    {'name': 'Smart V1 CCTV', 'image': 'assets/images/smart_camera.png'},
    {'name': 'Smart Webcam', 'image': 'assets/images/camera.webp'},
    {'name': 'Smart V2 CCTV', 'image': 'assets/images/smart_v2_cctv.jpg'},
    {'name': 'Smart Lamp', 'image': 'assets/images/smart_lamp.jpg'},
    {'name': 'Foster Speaker', 'image': 'assets/images/Foster.webp'},
    {'name': 'Module WiFi', 'image': 'assets/images/module_wifi.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _textDark, size: 24),
        ),
        title: Text(
          'Add Device',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Tabs ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNearbyTab = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isNearbyTab
                                ? _primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Provision',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: _isNearbyTab
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _isNearbyTab ? Colors.white : _textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNearbyTab = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_isNearbyTab
                                ? _primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Add Manual',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: !_isNearbyTab
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: !_isNearbyTab ? Colors.white : _textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Main Content ──────────────────────────────────────────
            Expanded(
              child: _isNearbyTab
                  ? _buildProvisionTab()
                  : _buildAddManualTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProvisionTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            'Looking for devices with QR codes',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 16),

          // instruction tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: _primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi, size: 12, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: _primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bluetooth,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Turn on your Wifi & Bluetooth to connect',
                  style: GoogleFonts.inter(fontSize: 12, color: _textGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          // ── QR Code Display ────────────────────────────────────────
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/QR.png',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 64),

          // Provision New Device Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ScanDeviceQrScreen(),
                    ),
                  );
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
                  'Provision New Device',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Can't find your devices?
          Center(
            child: Text.rich(
              TextSpan(
                text: "Can't find your devices? ",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: _textGrey,
                ),
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Navigate to help screen
                      },
                      child: Text(
                        'Learn more',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildAddManualTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Categories List
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategoryIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategoryIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? _primaryBlue
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    _categories[index],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : _textDark,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // 2-Column Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
            ),
            itemCount: _manualDevices.length,
            itemBuilder: (context, index) {
              final device = _manualDevices[index];
              return GestureDetector(
                onTap: () {
                  if (device['name'] == 'Smart Lamp') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LampConnectScreen(),
                      ),
                    );
                  } else if (device['name'] == 'Foster Speaker') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FosterConnectScreen(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ConnectToDeviceScreen(),
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCFCFC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            device['image']!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      device['name']!,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _textDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRadarCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _primaryBlue.withValues(alpha: opacity * 0.3),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildFloatingDevice(
    IconData icon,
    Offset offset,
    double scale, {
    bool isWide = false,
  }) {
    return Transform.translate(
      offset: offset,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: isWide ? 80 : 50,
          height: isWide ? 40 : 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Center(
            child: Icon(icon, color: _textDark, size: isWide ? 20 : 26),
          ),
        ),
      ),
    );
  }
}
