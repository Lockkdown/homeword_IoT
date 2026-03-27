import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mqtt_service.dart';

/// Màn hình điều khiển bóng đèn LED 5W AC qua relay GPIO 5
class LedBulbScreen extends StatefulWidget {
  const LedBulbScreen({super.key});

  @override
  State<LedBulbScreen> createState() => _LedBulbScreenState();
}

class _LedBulbScreenState extends State<LedBulbScreen> {
  bool _isOn = false;
  bool _isPublishing = false;
  final MqttService _mqtt = MqttService();

  @override
  void initState() {
    super.initState();
    _mqtt.connect();
  }

  @override
  void dispose() {
    _mqtt.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _toggle() async {
    if (_isPublishing) return;
    setState(() => _isPublishing = true);

    final next = !_isOn;
    final sent = await _mqtt.publishLedCommand(next);

    if (!mounted) return;
    if (!sent) {
      setState(() => _isPublishing = false);
      _showMessage('MQTT chưa kết nối, không gửi được lệnh.');
      return;
    }
    setState(() {
      _isOn = next;
      _isPublishing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Màu vàng ấm cho đèn LED 5W
    final Color warmYellow = const Color(0xFFFFC107);
    final Color warmYellowDark = const Color(0xFFFF8F00);

    return Scaffold(
      backgroundColor: const Color(0xFF22201A),
      body: FittedBox(
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 360,
          height: 800,
          child: Stack(
            children: [
              // ── Warm glow ─────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                left: _isOn ? 50 : 80,
                top: _isOn ? 170 : 230,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: _isOn ? 260 : 200,
                  height: _isOn ? 260 : 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: (_isOn ? warmYellow : Colors.black)
                            .withValues(alpha: _isOn ? 0.35 : 0.15),
                        blurRadius: _isOn ? 120 : 50,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Header ────────────────────────────
              Positioned(
                left: 28,
                right: 16,
                top: 52,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LED Bulb 5W',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    _buildMqttDot(),
                  ],
                ),
              ),

              // ── Bulb icon ─────────────────────────
              Positioned(
                left: 0,
                right: 0,
                top: 140,
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // glow outer ring
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: _isOn ? 200 : 160,
                          height: _isOn ? 200 : 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            boxShadow: _isOn
                                ? [
                                    BoxShadow(
                                      color: warmYellow.withValues(alpha: 0.25),
                                      blurRadius: 50,
                                      spreadRadius: 10,
                                    )
                                  ]
                                : [],
                          ),
                        ),
                        // main circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: _isOn
                                  ? [
                                      warmYellow.withValues(alpha: 0.95),
                                      warmYellowDark.withValues(alpha: 0.6),
                                      Colors.transparent,
                                    ]
                                  : [
                                      const Color(0xFF3D3828),
                                      const Color(0xFF2A2518),
                                      Colors.transparent,
                                    ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                        ),
                        // bulb icon
                        Icon(
                          _isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                          size: 64,
                          color: _isOn
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.25),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Watt info ─────────────────────────
              Positioned(
                left: 0,
                right: 0,
                top: 370,
                child: Column(
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: _isOn
                            ? warmYellow
                            : Colors.white.withValues(alpha: 0.15),
                      ),
                      child: const Text('5W', textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AC LED Bulb',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Device info ───────────────────────
              Positioned(
                left: 35,
                right: 35,
                top: 490,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bóng đèn LED 5W',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GPIO 5  ·  MQTT: tiny/led/command',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Toggle ────────────────────────────
              Positioned(
                left: 35,
                top: 575,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _isPublishing ? null : _toggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: 70,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(23),
                          color: _isOn
                              ? warmYellow.withValues(alpha: 0.75)
                              : const Color.fromRGBO(193, 193, 193, 0.2),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              left: _isOn ? 44.0 : 5.0,
                              top: 4.0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _isOn ? Colors.white : Colors.white38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isOn ? warmYellow : Colors.white38,
                      ),
                      child: Text(_isOn ? 'ON' : 'OFF'),
                    ),
                  ],
                ),
              ),

              // ── Status bar ────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: (_isOn ? warmYellow : Colors.white)
                          .withValues(alpha: 0.07),
                      border: Border.all(
                        color: (_isOn ? warmYellow : Colors.white)
                            .withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      _isOn ? '💡  Đèn đang sáng' : '○  Đèn đang tắt',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _isOn
                            ? warmYellow
                            : Colors.white.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMqttDot() {
    return ValueListenableBuilder<bool>(
      valueListenable: _mqtt.connectionStatus,
      builder: (context, isConnected, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isConnected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFEF5350),
                boxShadow: [
                  BoxShadow(
                    color: (isConnected
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFEF5350))
                        .withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isConnected ? 'Connected' : 'Disconnected',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        );
      },
    );
  }
}
