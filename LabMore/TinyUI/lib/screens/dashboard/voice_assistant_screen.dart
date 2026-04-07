import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 28,
                    color: Color(0xFF0D0D0D),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 1),
            Text(
              'We are listening...\nWhat do you want to do?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0xFF6B6B6B),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                '"Turn on all the lights in the entire room"',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0D0D0D),
                  height: 1.4,
                ),
              ),
            ),
            const Spacer(flex: 2),
            // Wave graphic placeholder
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFF9A9E),
                      Color(0xFF8EC5FC),
                      Color(0xFFE0C3FC),
                      Color(0xFFFECFEF),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.graphic_eq_rounded,
                        size: 160 + (_controller.value * 20),
                        color: Colors.white,
                      ),
                      Positioned(
                        top: 20,
                        child: Icon(
                          Icons.waves_rounded,
                          size: 120 + (_controller.value * 15),
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Spacer(flex: 2),
            // Siri Orb
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF00E1F0), // Bright cyan center
                    Color(0xFF536DFE), // Deep blue mid
                    Color(0xFFFF3366), // Pinkish red edge
                  ],
                  stops: [0.3, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E1F0).withValues(alpha: 0.3),
                    spreadRadius: 20,
                    blurRadius: 40,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF3366).withValues(alpha: 0.2),
                    spreadRadius: 40,
                    blurRadius: 60,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
