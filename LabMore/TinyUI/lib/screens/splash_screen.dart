import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'walkthrough_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Auto-navigate sang Walkthrough sau 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => WalkthroughScreen(
              onFinished: () {
                // TODO: navigate tới màn hình Login sau này
              },
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF536DFE),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Logo + App name (slightly above center) ──
            Align(
              alignment: const Alignment(0, -0.18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _SmartHomeIcon(size: 136),
                  const SizedBox(height: 28),
                  const Text(
                    'Smartify',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // ── Loading indicator (lower area) ──
            Align(
              alignment: const Alignment(0, 0.82),
              child: RotationTransition(
                turns: _rotationController,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    strokeWidth: 5.5,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    value: 0.8,
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

// ─────────────────────────────────────────────────────────────
//  Smart Home Icon: white rounded-pentagon + blue WiFi arcs
// ─────────────────────────────────────────────────────────────
class _SmartHomeIcon extends StatelessWidget {
  final double size;
  const _SmartHomeIcon({this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SmartHomePainter()),
    );
  }
}

class _SmartHomePainter extends CustomPainter {
  static const Color _bgColor = Colors.white;
  static const Color _iconColor = Color(0xFF536DFE);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── 1. Pentagon background ──
    final pentagonPath = _roundedPentagon(
      center: Offset(cx, cy),
      radius: size.width * 0.46,
      cornerRadius: 20,
    );
    canvas.drawPath(pentagonPath, Paint()..color = _bgColor);

    // ── 2. WiFi arcs ──
    final wifiOrigin = Offset(cx, cy + size.height * 0.08);
    _drawWifiIcon(canvas, wifiOrigin, size.width * 0.085);
  }

  void _drawWifiIcon(Canvas canvas, Offset origin, double baseRadius) {
    final arcPaint = Paint()
      ..color = _iconColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = baseRadius * 0.52;

    // NO center dot — design has none

    // 3 arcs face UPWARD: 210° clockwise +120° → ends at 330°, passes through 270°(top)
    const double startAngle = 7 * math.pi / 6; // 210°
    const double sweepAngle = 2 * math.pi / 3; // +120° clockwise → through top

    for (int i = 1; i <= 3; i++) {
      final r = baseRadius * (1.0 + i * 0.90);
      canvas.drawArc(
        Rect.fromCircle(center: origin, radius: r),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  /// Builds a rounded-corner regular pentagon.
  Path _roundedPentagon({
    required Offset center,
    required double radius,
    required double cornerRadius,
  }) {
    const int n = 5;
    const double startAngle = -math.pi / 2;

    final List<Offset> verts = List.generate(n, (i) {
      final angle = startAngle + (2 * math.pi * i / n);
      return Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    });

    final path = Path();

    for (int i = 0; i < n; i++) {
      final prev = verts[(i - 1 + n) % n];
      final curr = verts[i];
      final next = verts[(i + 1) % n];

      final toPrev = prev - curr;
      final toNext = next - curr;

      final cr = math.min(
        cornerRadius,
        math.min(toPrev.distance, toNext.distance) / 2,
      );

      final p1 = curr + Offset(toPrev.dx, toPrev.dy) / toPrev.distance * cr;
      final p2 = curr + Offset(toNext.dx, toNext.dy) / toNext.distance * cr;

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }

      path.quadraticBezierTo(curr.dx, curr.dy, p2.dx, p2.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
