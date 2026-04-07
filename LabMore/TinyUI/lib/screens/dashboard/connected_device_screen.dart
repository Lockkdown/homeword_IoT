import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectedDeviceScreen extends StatelessWidget {
  const ConnectedDeviceScreen({super.key});

  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight:
            0, // No appbar per design, only status bar padding handled by SafeArea
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Big Check Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: _primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.check, size: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Connected!',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You have connected to Smart V1 CCTV.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 18, color: _textGrey),
                    ),
                    const SizedBox(height: 60),
                    // Product Image Placeholder
                    Image.asset(
                      'assets/images/camera.webp',
                      width: 280,
                      height: 280,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => _goHome(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F4FF),
                          foregroundColor: _primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Go to Homepage',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Control Device',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
