import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'step3_rooms_screen.dart';

class Step2HomeNameScreen extends StatefulWidget {
  const Step2HomeNameScreen({super.key});

  @override
  State<Step2HomeNameScreen> createState() => _Step2HomeNameScreenState();
}

class _Step2HomeNameScreenState extends State<Step2HomeNameScreen> {
  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _bgLight = Color(0xFFF5F5F7);
  
  final TextEditingController _nameController = TextEditingController(text: 'My Home');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _skip() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const Step3RoomsScreen(),
    ));
  }

  void _continue() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const Step3RoomsScreen(),
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
                  
                  // Progress bar (Step 2/4)
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
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _primaryBlue,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const Expanded(flex: 2, child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Step count
                  Text(
                    '2 / 4',
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
                          TextSpan(text: 'Add '),
                          TextSpan(text: 'Home', style: TextStyle(color: _primaryBlue)),
                          TextSpan(text: ' Name'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  Center(
                    child: Text(
                      "Every smart home needs a name. What would you like to call yours?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: _textGrey,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Input Field
                  TextField(
                    controller: _nameController,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'My Home',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
