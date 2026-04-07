import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wifi_scan_screen.dart';

const Color _primaryBlue = Color(0xFF3B5BFA);
const Color _textDark = Color(0xFF1F2937);
const Color _textGrey = Color(0xFF6B7280);

class SetupCodeScreen extends StatefulWidget {
  const SetupCodeScreen({super.key});

  @override
  State<SetupCodeScreen> createState() => _SetupCodeScreenState();
}

class _SetupCodeScreenState extends State<SetupCodeScreen> {
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _textDark, size: 24),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Enter Device PIN',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Only applies to material devices only. Find the setup code on the device, packaging, or manual.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: _textGrey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // PIN Input Field
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: TextField(
                  controller: _pinController,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter PIN code',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textGrey,
                    ),
                    border: InputBorder.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final pin = _pinController.text.trim();
                    if (pin.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter PIN code',
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WifiScanScreen(deviceId: pin),
                      ),
                    );
                  },
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
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
