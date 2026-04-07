import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/esp_provisioning_service.dart';
import 'lamp_connecting_screen.dart';

const Color _primaryBlue = Color(0xFF3B5BFA);
const Color _textDark = Color(0xFF1F2937);
const Color _textGrey = Color(0xFF6B7280);

class WifiPasswordScreen extends StatefulWidget {
  final String ssid;
  final String deviceId;

  const WifiPasswordScreen({
    super.key,
    required this.ssid,
    required this.deviceId,
  });

  @override
  State<WifiPasswordScreen> createState() => _WifiPasswordScreenState();
}

class _WifiPasswordScreenState extends State<WifiPasswordScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isConnecting = false;
  late ESPProvisioningService _provisioningService;

  @override
  void initState() {
    super.initState();
    _provisioningService = ESPProvisioningService();
    _provisioningService.state.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _provisioningService.state.removeListener(_onStateChanged);
    _passwordController.dispose();
    _provisioningService.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;
    final s = _provisioningService.state.value;
    if (s == ProvisioningState.connected) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LampConnectingScreen(
            ssid: widget.ssid,
            password: _passwordController.text,
            deviceId: widget.deviceId,
          ),
        ),
      );
    } else if (s == ProvisioningState.failed) {
      setState(() => _isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_provisioningService.statusText.value),
          backgroundColor: Colors.red,
        ),
      );
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
          'WiFi Password',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF3FE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.wifi, color: _primaryBlue, size: 40),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.ssid,
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter password to connect',
                              style: GoogleFonts.inter(fontSize: 16, color: _textGrey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'Password',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.inter(fontSize: 16, color: _textDark),
                          decoration: InputDecoration(
                            hintText: 'Enter WiFi password',
                            hintStyle:
                                GoogleFonts.inter(fontSize: 16, color: _textGrey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: _textGrey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<String>(
                valueListenable: _provisioningService.statusText,
                builder: (context, statusMsg, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isConnecting ? null : _connectToDevice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isConnecting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    statusMsg,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Continue',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _connectToDevice() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter WiFi password',
              style: GoogleFonts.inter(fontSize: 14)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isConnecting = true);
    await _provisioningService.startProvisioning(
      ssid: widget.ssid,
      password: password,
    );
    // Navigation and error handling are done via _onStateChanged listener
  }
}
