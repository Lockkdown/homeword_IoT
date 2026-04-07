import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mqtt_service.dart';
import 'relay_control_screen.dart';
import 'led_bulb_screen.dart';
import 'power_monitor_screen.dart';

class HomeScreen extends StatelessWidget {
  final MqttService mqttService;

  const HomeScreen({super.key, required this.mqttService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141A18),
      body: FittedBox(
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 360,
          height: 800,
          child: Stack(
            children: [
              // ── Background subtle gradient ─────────
              Container(
                width: 360,
                height: 800,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A2420),
                      Color(0xFF141A18),
                      Color(0xFF1C1810),
                    ],
                  ),
                ),
              ),

              // ── Header ────────────────────────────
              Positioned(
                left: 28,
                right: 28,
                top: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TinyFlashBang',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ESP32  ·  GPIO 21  ·  MQTT Control',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Connection status
                    ValueListenableBuilder<bool>(
                      valueListenable: mqttService.connectionStatus,
                      builder: (context, connected, _) {
                        return Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: connected ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              connected ? 'MQTT Connected' : 'MQTT Disconnected',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: connected ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ── Section label ─────────────────────
              Positioned(
                left: 28,
                top: 168,
                child: Text(
                  'CHỌN CHẾ ĐỘ ĐIỀU KHIỂN',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.35),
                    letterSpacing: 1.8,
                  ),
                ),
              ),

              // ── Card 1: Power Monitor ─────────────
              Positioned(
                left: 20,
                right: 20,
                top: 196,
                child: _DeviceCard(
                  icon: Icons.monitor_heart_rounded,
                  iconColor: const Color(0xFF00BCD4),
                  bgGradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E2A2F), Color(0xFF152025)],
                  ),
                  borderColor: const Color(0xFF00BCD4),
                  title: 'Power Monitor',
                  subtitle: 'Theo dõi điện áp, dòng điện\ncông suất từ PZEM-004T',
                  badge: 'tiny/power/*',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PowerMonitorScreen(mqttService: mqttService),
                    ),
                  ),
                ),
              ),

              // ── Card 2: Relay ─────────────────────
              Positioned(
                left: 20,
                right: 20,
                top: 388,
                child: _DeviceCard(
                  icon: Icons.electrical_services_rounded,
                  iconColor: const Color(0xFF4CAF50),
                  bgGradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E2F23), Color(0xFF152018)],
                  ),
                  borderColor: const Color(0xFF4CAF50),
                  title: 'Relay Control',
                  subtitle: 'Bật/tắt đèn LED xanh\ntrên module relay 5V',
                  badge: 'tiny/relay/command',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RelayControlScreen(mqttService: mqttService),
                    ),
                  ),
                ),
              ),

              // ── Card 3: LED Bulb ──────────────────
              Positioned(
                left: 20,
                right: 20,
                top: 580,
                child: _DeviceCard(
                  icon: Icons.lightbulb_rounded,
                  iconColor: const Color(0xFFFFC107),
                  bgGradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2C2516), Color(0xFF1C1A0E)],
                  ),
                  borderColor: const Color(0xFFFFC107),
                  title: 'LED Bulb 5W',
                  subtitle: 'Bật/tắt bóng đèn LED 5W\nxoay chiều (AC)',
                  badge: 'tiny/led/command',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LedBulbScreen(),
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
}

// ── Reusable Card ─────────────────────────────────────────────
class _DeviceCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final LinearGradient bgGradient;
  final Color borderColor;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  const _DeviceCard({
    required this.icon,
    required this.iconColor,
    required this.bgGradient,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 170,
        decoration: BoxDecoration(
          gradient: widget.bgGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.borderColor.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.iconColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.iconColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: widget.iconColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(widget.icon, size: 30, color: widget.iconColor),
              ),
              const SizedBox(width: 18),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: widget.iconColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: widget.iconColor.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        widget.badge,
                        style: GoogleFonts.robotoMono(
                          fontSize: 10,
                          color: widget.iconColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
