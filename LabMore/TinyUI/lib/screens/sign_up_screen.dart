import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/device_manager.dart';
import 'dashboard/main_dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  late AnimationController _spinController;

  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);


  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đồng ý điều khoản để tiếp tục')),
      );
      return;
    }
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập email và mật khẩu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Username = email (backend accepts unique username; login bằng email)
      final res = await ApiService().register(
        username: email,
        email: email,
        password: password,
      );
      await ApiService().saveToken(res.token);
      await DeviceManager().refreshFromBackendOrCache();
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiService.messageFromError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Back button ───────────────────────────────────
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF0D0D0D), size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(height: 24),

                  // ── Title ─────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Join Smartify Today ',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                      ),
                      const Text('👤',
                          style: TextStyle(fontSize: 22, color: Color(0xFF6B9FBB))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join Smartify, Your Gateway to Smart Living.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: _textGrey,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Email field ───────────────────────────────────
                  Text('Email',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textDark)),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _emailController,
                    hint: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Color(0xFF9CA3AF), size: 20),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // ── Password field ────────────────────────────────
                  Text('Password',
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textDark)),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _passwordController,
                    hint: 'Password',
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF9CA3AF), size: 20),
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Checkbox terms ────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _agreedToTerms = !_agreedToTerms),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: _agreedToTerms
                                ? _primaryBlue
                                : Colors.transparent,
                            border: Border.all(
                              color: _agreedToTerms
                                  ? _primaryBlue
                                  : _primaryBlue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: _agreedToTerms
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 14)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                                fontSize: 13, color: _textDark),
                            children: [
                              const TextSpan(text: 'I agree to Smartify '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: _primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Already have account ──────────────────────────
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                            fontSize: 14, color: _textGrey),
                        children: [
                          const TextSpan(text: 'Already have an account?  '),
                          TextSpan(
                            text: 'Sign in',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: _primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Divider "or" ──────────────────────────────────
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: _textGrey)),
                      ),
                      const Expanded(
                          child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Social: Google ────────────────────────────────
                  _SignUpSocialButton(
                    label: 'Continue with Google',
                    icon: _SignUpGoogleIcon(),
                  ),
                  const SizedBox(height: 12),

                  // ── Social: Apple ─────────────────────────────────
                  _SignUpSocialButton(
                    label: 'Continue with Apple',
                    icon: const Icon(Icons.apple,
                        size: 24, color: Colors.black),
                  ),
                  const SizedBox(height: 28),

                  // ── Sign Up button ────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        'Sign up',
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),

        // ── Loading overlay dialog ──────────────────────────────────────
        if (_isLoading)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: Center(
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.symmetric(
                      vertical: 36, horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotationTransition(
                        turns: _spinController,
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            backgroundColor:
                                const Color(0xFF536DFE).withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF536DFE)),
                            value: 0.75,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sign up...',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0D0D0D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Reusable input field ─────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF0D0D0D)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF5F5F7),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 48),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF536DFE), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ─── Social button (sign up page) ────────────────────────────────────────────
class _SignUpSocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  const _SignUpSocialButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          children: [
            SizedBox(width: 26, height: 26, child: icon),
            const Expanded(child: SizedBox()),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0D0D0D),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

// ─── Google icon (perfect multicolor G) ──────────────────────────────────────────────────────────
class _SignUpGoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const String svgObj = '''
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
        <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
        <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
        <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
      </svg>
    ''';
    return SvgPicture.string(svgObj, width: 26, height: 26);
  }
}
