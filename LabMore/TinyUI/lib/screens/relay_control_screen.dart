import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mqtt_service.dart';

/// Màn hình điều khiển Relay – bật/tắt đèn LED xanh trên module relay
class RelayControlScreen extends StatefulWidget {
  const RelayControlScreen({super.key});

  @override
  State<RelayControlScreen> createState() => _RelayControlScreenState();
}

class _RelayControlScreenState extends State<RelayControlScreen>
    with SingleTickerProviderStateMixin {
  bool _isOn = false;
  bool _isPublishing = false;
  final MqttService _mqtt = MqttService();
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _mqtt.connect();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
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
    final sent = await _mqtt.publishRelayCommand(next);

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
    final Color accentOn = const Color(0xFF4CAF50);   // LED xanh relay
    final Color accentOff = const Color(0xFF546E5A);
    final Color accent = _isOn ? accentOn : accentOff;

    return Scaffold(
      backgroundColor: const Color(0xFF1A2420),
      body: FittedBox(
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 360,
          height: 800,
          child: Stack(
            children: [
              // ── Glow nền ──────────────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                left: _isOn ? 60 : 80,
                top: _isOn ? 240 : 260,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: _isOn ? 240 : 200,
                  height: _isOn ? 240 : 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: (_isOn ? accentOn : Colors.black)
                            .withValues(alpha: _isOn ? 0.55 : 0.2),
                        blurRadius: _isOn ? 100 : 60,
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
                      'Relay Control',
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

              // ── Relay icon ────────────────────────
              Positioned(
                left: 0,
                right: 0,
                top: 160,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _isOn ? _pulseAnim.value : 1.0,
                        child: child,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.12),
                        border: Border.all(
                          color: accent.withValues(alpha: _isOn ? 0.8 : 0.35),
                          width: 2,
                        ),
                        boxShadow: _isOn
                            ? [
                                BoxShadow(
                                  color: accentOn.withValues(alpha: 0.3),
                                  blurRadius: 32,
                                  spreadRadius: 4,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: _isOn ? 0.9 : 0.25),
                          ),
                          child: Icon(
                            Icons.electrical_services_rounded,
                            size: 40,
                            color: Colors.white.withValues(alpha: _isOn ? 1 : 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── LED xanh relay indicator ──────────
              Positioned(
                left: 0,
                right: 0,
                top: 370,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOn ? accentOn : const Color(0xFF2E3D30),
                        boxShadow: _isOn
                            ? [
                                BoxShadow(
                                  color: accentOn.withValues(alpha: 0.7),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isOn ? 'LED Xanh  ●  Đang sáng' : 'LED Xanh  ○  Tắt',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _isOn
                            ? accentOn
                            : Colors.white.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Device name ───────────────────────
              Positioned(
                left: 35,
                right: 35,
                top: 490,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Module Relay 5V 10A',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GPIO 5  ·  MQTT: tiny/relay/command',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Toggle ────────────────────────────
              Positioned(
                left: 35,
                top: 578,
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
                              ? accentOn.withValues(alpha: 0.7)
                              : const Color.fromRGBO(193, 193, 193, 0.25),
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
                                  color: _isOn ? Colors.white : Colors.white60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isOn ? 'ON' : 'OFF',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isOn ? accentOn : Colors.white54,
                      ),
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
                      color: (_isOn ? accentOn : Colors.white)
                          .withValues(alpha: 0.07),
                      border: Border.all(
                        color: (_isOn ? accentOn : Colors.white)
                            .withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      _isOn
                          ? '⚡  Relay đang hoạt động'
                          : '○  Relay đang nghỉ',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _isOn
                            ? accentOn
                            : Colors.white.withValues(alpha: 0.4),
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
