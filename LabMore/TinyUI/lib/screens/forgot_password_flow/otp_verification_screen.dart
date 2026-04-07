import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'create_new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  
  String _otp = '745';
  
  void _onKeypadTap(String value) {
    if (value == '<') {
      if (_otp.isNotEmpty) {
        setState(() {
          _otp = _otp.substring(0, _otp.length - 1);
        });
      }
    } else if (value == '*') {
      // Do nothing or handle wildcard
    } else {
      if (_otp.length < 4) {
        setState(() {
          _otp += value;
        });
        if (_otp.length == 4) {
          _verifyOtp();
        }
      }
    }
  }

  void _verifyOtp() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => const CreateNewPasswordScreen(),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 16, bottom: 10),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: _textDark, size: 24),
                  ),
                ),
              ],
            ),
            
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'Enter OTP Code 🔐',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Please check your email inbox for a message from Smartify. Enter the one-time verification code below.",
                            style: GoogleFonts.inter(fontSize: 15, color: _textGrey, height: 1.5),
                          ),
                          const SizedBox(height: 48),
                          
                          // OTP Input Boxes
                          Row(
                            children: List.generate(4, (index) {
                              bool isActive = index == _otp.length;
                              bool isFilled = index < _otp.length;
                              String digit = isFilled ? _otp[index] : '';
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: isActive ? const Color(0xFFF0F4FF) : const Color(0xFFFAFAFA),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isActive ? _primaryBlue : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      digit,
                                      style: GoogleFonts.inter(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: _textDark,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 48),
                          
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.inter(fontSize: 15, color: _textGrey),
                                children: const [
                                  TextSpan(text: 'You can resend the code in '),
                                  TextSpan(text: '56', style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600)),
                                  TextSpan(text: ' seconds'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child:
                            Text(
                              'Resend code',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: const Color(0xFFA0A0A0),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Custom Numpad
                  Container(
                    color: const Color(0xFFFAFAFA),
                    padding: const EdgeInsets.only(top: 24, bottom: 40),
                    child: Column(
                      children: [
                        _buildKeyboardRow(['1', '2', '3']),
                        const SizedBox(height: 16),
                        _buildKeyboardRow(['4', '5', '6']),
                        const SizedBox(height: 16),
                        _buildKeyboardRow(['7', '8', '9']),
                        const SizedBox(height: 16),
                        _buildKeyboardRow(['*', '0', '<']),
                      ],
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

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        return InkWell(
          onTap: () => _onKeypadTap(key),
          splashColor: Colors.black12,
          customBorder: const CircleBorder(),
          child: Container(
            width: 80,
            height: 60,
            alignment: Alignment.center,
            child: key == '<' 
              ? const Icon(Icons.backspace_outlined, color: _textDark, size: 24)
              : Text(
                  key,
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w500, color: _textDark),
                ),
          ),
        );
      }).toList(),
    );
  }
}
