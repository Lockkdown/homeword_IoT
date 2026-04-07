import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'connected_device_screen.dart';

class ConnectingToDeviceScreen extends StatefulWidget {
  const ConnectingToDeviceScreen({super.key});

  @override
  State<ConnectingToDeviceScreen> createState() =>
      _ConnectingToDeviceScreenState();
}

class _ConnectingToDeviceScreenState extends State<ConnectingToDeviceScreen>
    with SingleTickerProviderStateMixin {
  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);

  bool _isNearbyTab = true;
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
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutSine),
    );

    _progressController.forward();

    // Auto navigation to next screen at the end of progress
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ConnectedDeviceScreen()),
          );
        }
      }
    });
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
          'Add Device',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              color: _textDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Tabs ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNearbyTab = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isNearbyTab
                                ? _primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Nearby Devices',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: _isNearbyTab
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _isNearbyTab ? Colors.white : _textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isNearbyTab = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_isNearbyTab
                                ? _primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Add Manual',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: !_isNearbyTab
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: !_isNearbyTab ? Colors.white : _textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'Connect to device',
                      style: GoogleFonts.inter(
                        fontSize: 24,
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
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Device status tag
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: _primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Smart V1 CCTV',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: _textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    // Circular Progress with Image
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        int percent = (_progressAnimation.value * 100).toInt();
                        return Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 280,
                                  height: 280,
                                  child: CircularProgressIndicator(
                                    value: _progressAnimation.value,
                                    strokeWidth: 6,
                                    backgroundColor: const Color(0xFFF0F0F0),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          _primaryBlue,
                                        ),
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/camera.webp',
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                            const SizedBox(height: 48),
                            Text(
                              'Connecting...',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: _textGrey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$percent%',
                              style: GoogleFonts.inter(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: _primaryBlue,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 64),
                    Text(
                      "Can't connect with your devices?",
                      style: GoogleFonts.inter(fontSize: 15, color: _textGrey),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Learn more',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
