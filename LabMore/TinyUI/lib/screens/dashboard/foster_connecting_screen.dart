import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'foster_connected_screen.dart';

const Color _primaryBlue = Color(0xFF3B5BFA);
const Color _textDark = Color(0xFF1F2937);
const Color _textGrey = Color(0xFF6B7280);

class FosterConnectingScreen extends StatefulWidget {
  const FosterConnectingScreen({super.key});

  @override
  State<FosterConnectingScreen> createState() => _FosterConnectingScreenState();
}

class _FosterConnectingScreenState extends State<FosterConnectingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // Auto-navigate when complete
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const FosterConnectedScreen()),
        );
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _textDark, size: 24),
        ),
        title: Text(
          'Device Detected',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: _textDark, size: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Page Title
              Text(
                'Connect to device',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 16),

              // instruction tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: _primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: _primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bluetooth,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Turn on your Wifi & Bluetooth to connect',
                      style: GoogleFonts.inter(fontSize: 12, color: _textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Checkbox row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: _primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Stereo Speaker',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: _textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Progress Circular UI
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Ring
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF3F4F6),
                              width: 6,
                            ),
                          ),
                        ),
                        // Progress Sweep
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: CircularProgressIndicator(
                            value: _progressAnimation.value,
                            strokeWidth: 6,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              _primaryBlue,
                            ),
                          ),
                        ),
                        // Foster Speaker Image
                        Image.asset(
                          'assets/images/Foster.webp',
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // Status Text
              Text(
                'Connecting...',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Percentage
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  int percentage = (_progressAnimation.value * 100).toInt();
                  return Text(
                    '$percentage%',
                    style: GoogleFonts.inter(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: _primaryBlue,
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              Text(
                "Can't connect with your devices?",
                style: GoogleFonts.inter(fontSize: 14, color: _textGrey),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Learn more',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
