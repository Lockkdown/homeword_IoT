import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'wifi_scan_screen.dart';
import 'setup_code_screen.dart';

class ScanDeviceQrScreen extends StatefulWidget {
  const ScanDeviceQrScreen({super.key});

  @override
  State<ScanDeviceQrScreen> createState() => _ScanDeviceQrScreenState();
}

class _ScanDeviceQrScreenState extends State<ScanDeviceQrScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 300.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Camera permission is required to scan QR codes',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onBarcodeCapture(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final jsonData = jsonDecode(barcode.rawValue!) as Map<String, dynamic>;

      String? deviceId;

      // Format 1: ESP-IDF BLE provisioning format
      // {"ver":"v1","name":"PROV_SMARTLAMP","pop":"abcd1234","transport":"ble"}
      if (jsonData.containsKey('name') && jsonData.containsKey('transport')) {
        final transport = jsonData['transport'] as String?;
        final name = jsonData['name'] as String?;
        if (transport == 'ble' && name != null) {
          deviceId = name;
        }
      }

      // Format 2: legacy app format {"device_id":"...","type":"lamp"}
      if (deviceId == null &&
          jsonData.containsKey('device_id') &&
          jsonData['type'] == 'lamp') {
        deviceId = jsonData['device_id'] as String?;
      }

      if (deviceId != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => WifiScanScreen(deviceId: deviceId!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid QR code format',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to parse QR code: $e',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background behind image if needed
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Scanner
          MobileScanner(
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                _onBarcodeCapture(capture);
              }
            },
          ),

          // Scanner Overlay
          Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _buildCorner(top: true, left: true),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _buildCorner(top: true, left: false),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _buildCorner(top: false, left: true),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _buildCorner(top: false, left: false),
                  ),
                  // Scan Line
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _scanAnimation.value,
                        left: 0,
                        right: 0,
                        child: child!,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // SafeArea overlay
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Top Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Text(
                        'Scan Device',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // "Can't scan the QR code?" text
                Text(
                  "Can't scan the QR code?",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Enter setup code manually button
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SetupCodeScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Enter setup code manually',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Bottom Controls Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Folder Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.folder_outlined,
                          color: Colors.white,
                        ),
                      ),

                      // Shutter Button
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(
                              0xFF3B5BFA,
                            ), // Primary blue border
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),

                      // Gallery Icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          bottom: !top
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          left: left
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
          right: !left
              ? const BorderSide(color: Colors.white, width: 4)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(20) : Radius.zero,
          topRight: top && !left ? const Radius.circular(20) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(20) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(20) : Radius.zero,
        ),
      ),
    );
  }
}
