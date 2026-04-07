import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _bgLight = Color(0xFFEEEEF5);

  void _signIn(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const SignInScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // ── Logo ─────────────────────────────────────────────────
              const _SmartifyLogoIcon(size: 90),
              const SizedBox(height: 36),

              // ── Title ─────────────────────────────────────────────────
              Text(
                "Let's Get Started!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Let's dive in into your account",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: _textGrey,
                ),
              ),
              const SizedBox(height: 36),

              // ── Social buttons ──────────────────────────────────────
              _SocialButton(
                label: 'Continue with Google',
                icon: _GoogleIcon(),
              ),
              const SizedBox(height: 14),
              _SocialButton(
                label: 'Continue with Apple',
                icon: const Icon(Icons.apple, size: 26, color: Colors.black),
              ),
              const SizedBox(height: 14),
              _SocialButton(
                label: 'Continue with Facebook',
                icon: const _FacebookIcon(),
              ),
              const SizedBox(height: 14),
              _SocialButton(
                label: 'Continue with Twitter',
                icon: const _TwitterIcon(),
              ),
              const SizedBox(height: 28),

              // ── Sign up button ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SignUpScreen(),
                    ));
                  },
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Sign in button ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 58,
                child: TextButton(
                  onPressed: () => _signIn(context),
                  style: TextButton.styleFrom(
                    backgroundColor: _bgLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    'Sign in',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Footer ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Privacy Policy',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _textGrey,
                      ),
                    ),
                  ),
                  Text(
                    ' · ',
                    style: GoogleFonts.inter(fontSize: 13, color: _textGrey),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Terms of Service',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _textGrey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Social button chung ─────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;

  const _SocialButton({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
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
            SizedBox(width: 28, height: 28, child: icon),
            const Expanded(child: SizedBox()),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
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

// ─── Logo icon (blue pentagon + white wifi) ──────────────────────────────────
class _SmartifyLogoIcon extends StatelessWidget {
  final double size;
  const _SmartifyLogoIcon({this.size = 90});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  static const Color _bgColor = Color(0xFF536DFE);
  static const Color _iconColor = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Pentagon (blue)
    final path = _roundedPentagon(Offset(cx, cy), size.width * 0.46, 14);
    canvas.drawPath(path, Paint()..color = _bgColor);

    // WiFi arcs (white)
    final origin = Offset(cx, cy + size.height * 0.08);
    final baseR = size.width * 0.085;
    final arcPaint = Paint()
      ..color = _iconColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = baseR * 0.52;

    const startAngle = 7 * math.pi / 6;
    const sweepAngle = 2 * math.pi / 3;

    for (int i = 1; i <= 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: origin, radius: baseR * (1.0 + i * 0.90)),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  Path _roundedPentagon(Offset center, double radius, double cr) {
    const n = 5;
    const start = -math.pi / 2;
    final verts = List.generate(n, (i) {
      final a = start + 2 * math.pi * i / n;
      return Offset(center.dx + radius * math.cos(a),
          center.dy + radius * math.sin(a));
    });
    final path = Path();
    for (int i = 0; i < n; i++) {
      final prev = verts[(i - 1 + n) % n];
      final curr = verts[i];
      final next = verts[(i + 1) % n];
      final tp = prev - curr;
      final tn = next - curr;
      final r = math.min(cr, math.min(tp.distance, tn.distance) / 2);
      final p1 = curr + tp / tp.distance * r;
      final p2 = curr + tn / tn.distance * r;
      if (i == 0) path.moveTo(p1.dx, p1.dy);
      else path.lineTo(p1.dx, p1.dy);
      path.quadraticBezierTo(curr.dx, curr.dy, p2.dx, p2.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Google Icon (perfect multicolor G) ──────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
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
    return SvgPicture.string(svgObj, width: 28, height: 28);
  }
}

// ─── Facebook Icon ────────────────────────────────────────────────────────────
class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      child: const Padding(
        padding: EdgeInsets.only(bottom: 1),
        child: Center(
          child: Text(
            'f',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Twitter Bird Icon ────────────────────────────────────────────────────────
class _TwitterIcon extends StatelessWidget {
  const _TwitterIcon();
  @override
  Widget build(BuildContext context) {
    const String birdSvg = '''
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z" fill="#1DA1F2"/>
      </svg>
    ''';
    return SvgPicture.string(birdSvg, width: 28, height: 28);
  }
}
