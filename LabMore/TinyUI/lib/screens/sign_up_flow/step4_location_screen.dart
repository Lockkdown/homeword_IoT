import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'step5_completed_screen.dart';

class Step4LocationScreen extends StatefulWidget {
  const Step4LocationScreen({super.key});

  @override
  State<Step4LocationScreen> createState() => _Step4LocationScreenState();
}

class _Step4LocationScreenState extends State<Step4LocationScreen> {
  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _bgLight = Color(0xFFF5F5F7);
  
  final TextEditingController _addressController = TextEditingController(text: '701 7th Ave, New York, 10036, USA');

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _skip() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const Step5CompletedScreen(),
    ));
  }

  void _continue() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const Step5CompletedScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (Appbar + Progress) ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 16, right: 24, bottom: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: _textDark, size: 22),
                      ),
                      const SizedBox(width: 8),

                      // Progress bar (Step 4/4)
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: _bgLight,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _primaryBlue,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Step count
                      Text(
                        '4 / 4',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Content ──────────────────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 24),

                      // Title
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                              height: 1.3,
                            ),
                            children: const [
                              TextSpan(text: 'Set Home '),
                              TextSpan(text: 'Location', style: TextStyle(color: _primaryBlue)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Center(
                        child: Text(
                          "Pin your home's location to enhance location-based features. Privacy is our priority.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: _textGrey,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Map Placeholder (Mockup)
                      AspectRatio(
                        aspectRatio: 0.95,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6), // Gray placeholder
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              // Fake map background pattern
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.5,
                                  child: CustomPaint(
                                    painter: _FakeMapGridPainter(),
                                  ),
                                ),
                              ),
                              // Map marker
                              const Center(
                                child: _MapMarkerIcon(size: 80),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        'Address Details',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Address Input Field
                      TextField(
                        controller: _addressController,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: _textDark,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Address Details',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFA0A0A0),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // ── Footer Buttons ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 54,
                          child: TextButton(
                            onPressed: _skip,
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFEEEEF5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _primaryBlue,
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
                            onPressed: _continue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: Text(
                              'Continue',
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

// Map Grid Fake background
class _FakeMapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.2);
    path.lineTo(size.width * 0.6, size.height * 0.8);
    path.lineTo(size.width, size.height * 0.6);

    path.moveTo(size.width * 0.3, 0);
    path.lineTo(size.width * 0.4, size.height * 0.5);
    path.lineTo(0, size.height * 0.7);

    path.moveTo(size.width * 0.7, 0);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.9);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// Beautiful Map Marker Icon
class _MapMarkerIcon extends StatelessWidget {
  final double size;
  const _MapMarkerIcon({this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.3,
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.location_on,
            color: const Color(0xFF536DFE),
            size: size,
          ),
          Positioned(
            top: size * 0.16,
            child: Container(
              width: size * 0.45,
              height: size * 0.45,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: const Color(0xFFA0A0A0),
                size: size * 0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
