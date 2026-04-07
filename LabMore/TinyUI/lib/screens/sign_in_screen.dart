import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../services/device_manager.dart';
import 'dashboard/main_dashboard_screen.dart';
import 'forgot_password_flow/forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _inputBg = Color(0xFFFAFAFA);
  static const Color _inputHint = Color(0xFFA0A0A0);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập email và mật khẩu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService().login(username: email, password: password);
      await ApiService().saveToken(res.token);
      // Refresh device list từ backend (không block nếu fail)
      await DeviceManager().refreshFromBackendOrCache().catchError((_) {});
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
        (route) => false,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = ApiService.messageFromError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Lọc lỗi MQTT ra khỏi màn hình đăng nhập
      final msg = e.toString();
      final isMqttError = msg.contains('connection errored') ||
          msg.contains('no route to host') ||
          msg.contains('cannot be solved by the library');
      if (!isMqttError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiService.messageFromError(e))),
        );
      }
    }
  }

  void _forgotPassword() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const ForgotPasswordScreen(),
    ));
  }

  void _socialSignIn(String provider) {
    // handle social sigin
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header (Appbar) ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 16, bottom: 10),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: _textDark, size: 24),
                  ),
                ),

                // ── Content ──────────────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        
                        // Title
                        Text(
                          'Welcome Back! 👋',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          'Your Smart Home, Your Rules.',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: _textGrey,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Form Fields
                        Text(
                          'Email',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: _textDark),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: GoogleFonts.inter(fontSize: 15, color: _inputHint),
                            filled: true,
                            fillColor: _inputBg,
                            prefixIcon: const Icon(Icons.mail_outline, color: _textDark, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'Password',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          obscuringCharacter: '●',
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark, letterSpacing: 2),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: GoogleFonts.inter(fontSize: 15, color: _inputHint, fontWeight: FontWeight.normal, letterSpacing: 0),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: _rememberMe ? _primaryBlue : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: _rememberMe ? _primaryBlue : _textDark,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: _rememberMe
                                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Remember me',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: _textDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _forgotPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: _primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // OR separator
                        Row(
                          children: [
                            Expanded(child: Container(height: 1, color: const Color(0xFFE5E7EB))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: _textGrey,
                                ),
                              ),
                            ),
                            Expanded(child: Container(height: 1, color: const Color(0xFFE5E7EB))),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Social Buttons
                        _SocialAuthButton(
                          svgIcon: const _SignInGoogleIcon(),
                          text: 'Continue with Google',
                          onPressed: () => _socialSignIn('Google'),
                        ),
                        const SizedBox(height: 16),
                        _SocialAuthButton(
                          svgIcon: const _AppleIcon(),
                          text: 'Continue with Apple',
                          onPressed: () => _socialSignIn('Apple'),
                        ),
                        const SizedBox(height: 16),
                        _SocialAuthButton(
                          svgIcon: const _FacebookIcon(),
                          text: 'Continue with Facebook',
                          onPressed: () => _socialSignIn('Facebook'),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // ── Footer Button ──────────────────────────────────────────
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
                      onPressed: _isLoading ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        disabledBackgroundColor: _primaryBlue.withValues(alpha: 0.6),
                      ),
                      child: Text(
                        'Sign in',
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
        ),

        // ── Loading Dialog Overlay ──────────────────────────────
        if (_isLoading)
          Stack(
            children: [
              // Blur background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.25),
                ),
              ),
              // Dialog Box
              Center(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0.9, end: 1.0),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                strokeWidth: 5,
                                color: _primaryBlue,
                                backgroundColor: Color(0xFFE8EAF6),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Sign in...',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UI Components for Buttons & Icons
// ─────────────────────────────────────────────────────────────────────────────

class _SocialAuthButton extends StatelessWidget {
  final Widget svgIcon;
  final String text;
  final VoidCallback onPressed;

  const _SocialAuthButton({
    required this.svgIcon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24, height: 24, child: svgIcon),
            const SizedBox(width: 16),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0D0D0D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Standard multi-color SVG Google 'G'
class _SignInGoogleIcon extends StatelessWidget {
  const _SignInGoogleIcon();
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/></svg>',
    );
  }
}

class _AppleIcon extends StatelessWidget {
  const _AppleIcon();
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.apple, color: Colors.black, size: 26);
  }
}

// Standard SVG for Facebook f
class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="#1877F2" d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.469h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.469h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/><path fill="#ffffff" d="M16.671 15.542l.532-3.469h-3.328v-2.25c0-.949.465-1.874 1.956-1.874h1.514V5.003s-1.374-.235-2.686-.235c-2.741 0-4.533 1.662-4.533 4.669v2.637H7.078v3.469h3.048v8.385a12.19 12.19 0 003.749 0v-8.385h2.796z"/></svg>',
    );
  }
}
