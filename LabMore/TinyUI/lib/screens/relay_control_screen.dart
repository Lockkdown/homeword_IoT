import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/mqtt_service.dart';

class RelayControlScreen extends StatefulWidget {
  final MqttService mqttService;

  const RelayControlScreen({super.key, required this.mqttService});

  @override
  State<RelayControlScreen> createState() => _RelayControlScreenState();
}

class _RelayControlScreenState extends State<RelayControlScreen>
    with SingleTickerProviderStateMixin {
  bool _isPublishing = false;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
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

    final newState = !widget.mqttService.relayState.value;
    final ok = await widget.mqttService.publishRelayCommand(newState);

    if (!mounted) return;
    setState(() => _isPublishing = false);

    if (ok) {
      _showMessage(newState ? 'Relay ON → đã gửi' : 'Relay OFF → đã gửi');
    } else {
      _showMessage('MQTT chưa kết nối');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.mqttService.relayState,
      builder: (context, isOn, _) {
        final Color accentOn = const Color(0xFF4CAF50);
        final Color accentOff = const Color(0xFF546E5A);
        final Color accent = isOn ? accentOn : accentOff;

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
                  // Glow background
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    left: isOn ? 60 : 80,
                    top: isOn ? 240 : 260,
                    child: AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (context, child) {
                        return Opacity(
                          opacity: isOn ? _pulseAnim.value : 1.0,
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
                            color: accent.withValues(alpha: isOn ? 0.8 : 0.35),
                            width: 2,
                          ),
                          boxShadow: isOn
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
                              color: accent.withValues(alpha: isOn ? 0.9 : 0.25),
                            ),
                            child: Icon(
                              Icons.electrical_services_rounded,
                              size: 40,
                              color: Colors.white.withValues(alpha: isOn ? 1 : 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // LED indicator
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 420,
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOn ? accentOn : const Color(0xFF2E3D30),
                            boxShadow: isOn
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
                          isOn ? 'LED Xanh  ●  Đang sáng' : 'LED Xanh  ○  Tắt',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isOn
                                ? accentOn
                                : Colors.white.withValues(alpha: 0.4),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Device info
                  Positioned(
                    left: 35,
                    right: 35,
                    top: 500,
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
                          'GPIO 21  ·  MQTT: tiny/relay/command',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.sync,
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'tiny/relay/state',
                              style: GoogleFonts.robotoMono(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Toggle switch
                  Positioned(
                    left: 35,
                    top: 620,
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
                              color: isOn
                                  ? accentOn.withValues(alpha: 0.7)
                                  : const Color.fromRGBO(193, 193, 193, 0.25),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  left: isOn ? 44.0 : 5.0,
                                  top: 4.0,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isOn ? Colors.white : Colors.white60,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isOn ? 'ON' : 'OFF',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isOn ? accentOn : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 50,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: (isOn ? accentOn : Colors.white)
                              .withValues(alpha: 0.07),
                          border: Border.all(
                            color: (isOn ? accentOn : Colors.white)
                                .withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          isOn
                              ? '⚡  Relay đang hoạt động'
                              : '○  Relay đang nghỉ',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isOn
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
      },
    );
  }
}
