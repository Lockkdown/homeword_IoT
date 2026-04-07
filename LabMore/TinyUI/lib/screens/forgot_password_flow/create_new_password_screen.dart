import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'reset_password_success_screen.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _inputBg = Color(0xFFFAFAFA);

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _saveNewPassword() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ResetPasswordSuccessScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, bottom: 10),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: _textDark, size: 24),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Secure Your Account 🔒',
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Almost there! Create a new password for your Smartify account to keep it secure. Remember to choose a strong and unique password.",
                      style: GoogleFonts.inter(fontSize: 15, color: _textGrey, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      'New Password',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      obscureText: _obscurePassword,
                      obscuringCharacter: '●',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark, letterSpacing: 2),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _inputBg,
                        prefixIcon: const Icon(Icons.lock_outline, color: _textDark, size: 20),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: _textDark,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    Text(
                      'Confirm New Password',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: _textDark),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      obscureText: _obscureConfirmPassword,
                      obscuringCharacter: '●',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark, letterSpacing: 2),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _inputBg,
                        prefixIcon: const Icon(Icons.lock_outline, color: _textDark, size: 20),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          child: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: _textDark,
                            size: 20,
                          ),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveNewPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    'Save New Password',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
