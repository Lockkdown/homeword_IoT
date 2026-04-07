import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../dashboard/main_dashboard_screen.dart';

class Step5CompletedScreen extends StatelessWidget {
  const Step5CompletedScreen({super.key});

  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);

  void _getStarted(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainDashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (Appbar + Close) ──────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 24, right: 24, bottom: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: _textDark, size: 26),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dynamic Check Illustration
                        const _SuccessIllustration(),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Well Done!',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          'Congratulations! Your home is now a Smartify haven. Start exploring and managing your smart space with ease.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: _textGrey,
                            height: 1.5,
                          ),
                        ),
                        
                        // Push the content slightly up by adding bottom padding block
                        SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Footer Buttons ──────────────────────────────────────────
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
                  onPressed: () => _getStarted(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Get Started',
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
    );
  }
}

// Custom Painter for the blue circular checkmark with dots
class _SuccessIllustration extends StatefulWidget {
  const _SuccessIllustration();

  @override
  State<_SuccessIllustration> createState() => _SuccessIllustrationState();
}

class _SuccessIllustrationState extends State<_SuccessIllustration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        width: 140,
        height: 140,
        child: CustomPaint(
          painter: _CheckmarkPainter(),
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final primaryBlue = const Color(0xFF536DFE);

    // Main Circle
    final circlePaint = Paint()
      ..color = primaryBlue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 44, circlePaint);

    // Checkmark
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    final path = Path();
    path.moveTo(cx - 12, cy + 2);
    path.lineTo(cx - 3, cy + 11);
    path.lineTo(cx + 14, cy - 8);
    canvas.drawPath(path, checkPaint);

    // Decorative dots (randomly placed as per design mockup)
    final dotPaint = Paint()
      ..color = primaryBlue
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(cx - 50, cy - 25), 6, dotPaint);
    canvas.drawCircle(Offset(cx + 50, cy - 18), 4.5, dotPaint);
    canvas.drawCircle(Offset(cx - 52, cy + 18), 3, dotPaint);
    canvas.drawCircle(Offset(cx + 46, cy + 12), 1.5, dotPaint);
    canvas.drawCircle(Offset(cx - 16, cy + 62), 2, dotPaint);
    canvas.drawCircle(Offset(cx + 10, cy - 58), 1.5, dotPaint);
    canvas.drawCircle(Offset(cx + 44, cy + 34), 1.5, dotPaint);
    canvas.drawCircle(Offset(cx - 55, cy - 2), 1, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
