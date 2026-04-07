import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/esp_provisioning_service.dart';
import 'wifi_password_screen.dart';

const Color _primaryBlue = Color(0xFF3B5BFA);
const Color _textDark = Color(0xFF1F2937);
const Color _textGrey = Color(0xFF6B7280);

class WifiScanScreen extends StatefulWidget {
  final String deviceId;

  const WifiScanScreen({super.key, required this.deviceId});

  @override
  State<WifiScanScreen> createState() => _WifiScanScreenState();
}

class _WifiScanScreenState extends State<WifiScanScreen> {
  final ESPProvisioningService _provService = ESPProvisioningService();
  bool _isScanning = false;
  List<String> _wifiList = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _scanWifiViaESP32();
  }

  Future<void> _scanWifiViaESP32() async {
    setState(() {
      _isScanning = true;
      _error = null;
    });

    final networks = await _provService.getWifiNetworksFromDevice();

    if (mounted) {
      if (_provService.state.value == ProvisioningState.failed) {
        setState(() {
          _error = _provService.statusText.value;
          _isScanning = false;
        });
      } else {
        setState(() {
          // Lọc trùng lặp do ESP32 có thể trả về các AP có cùng SSID
          _wifiList = networks.toSet().toList();
          _isScanning = false;
        });
      }
    }
  }

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
          'Select WiFi Network',
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
            // Instruction
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF3FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: _primaryBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ESP32 is looking for WiFi networks around it. Select one to connect.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Error UI
            if (_error != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: GoogleFonts.inter(
                                fontSize: 14, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _scanWifiViaESP32,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text('Retry',
                              style: GoogleFonts.inter(fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Loading state
            if (_isScanning)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: _primaryBlue),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<String>(
                        valueListenable: _provService.statusText,
                        builder: (context, status, _) {
                          return Text(
                            status,
                            style: GoogleFonts.inter(color: _textGrey),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // WiFi List
            if (!_isScanning && _error == null)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _scanWifiViaESP32,
                  color: _primaryBlue,
                  child: _wifiList.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.wifi_off, size: 48, color: _textGrey),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No networks found',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        color: _textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pull to refresh',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: _textGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _wifiList.length,
                          itemBuilder: (context, index) {
                            final ssid = _wifiList[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => WifiPasswordScreen(
                                        ssid: ssid,
                                        deviceId: widget.deviceId,
                                      ),
                                    ),
                                  );
                                },
                                leading: const Icon(Icons.wifi, color: Colors.green, size: 20),
                                title: Text(
                                  ssid,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _textDark,
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right, size: 20, color: _textGrey),
                              ),
                            );
                          },
                        ),
                ),
              ),

            // Scan Button
            if (!_isScanning && _error == null)
              Container(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _scanWifiViaESP32,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: Text(
                      'Scan Again',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
