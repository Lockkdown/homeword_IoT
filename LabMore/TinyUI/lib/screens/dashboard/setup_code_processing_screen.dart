import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SetupCodeProcessingScreen extends StatefulWidget {
  const SetupCodeProcessingScreen({super.key});

  @override
  State<SetupCodeProcessingScreen> createState() =>
      _SetupCodeProcessingScreenState();
}

class _SetupCodeProcessingScreenState extends State<SetupCodeProcessingScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate processing time then return to root
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // Let BackdropFilter handle background
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.black.withValues(alpha: 0.5), // dim background
          child: Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF3B5BFA),
                      ),
                      backgroundColor: Color(0xFFEFF3FE),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Processing Device...',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
