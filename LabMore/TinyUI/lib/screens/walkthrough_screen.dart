import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_screen.dart';

// ─── Data model cho mỗi trang walkthrough ───────────────────────────────────
class _WalkthroughPage {
  final String imagePath; // Absolute path tới ảnh mockup
  final String title;
  final String subtitle;

  const _WalkthroughPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

// ─── Danh sách 3 trang ───────────────────────────────────────────────────────
const List<_WalkthroughPage> _pages = [
  _WalkthroughPage(
    imagePath: 'assets/images/walkthrough1.png',
    title: 'Empower Your Home,\nSimplify Your Life',
    subtitle:
        'Transform your living space into a smarter,\nmore connected home with Smartify.\nAll at your fingertips.',
  ),
  _WalkthroughPage(
    imagePath: 'assets/images/walkthrough2.png',
    title: 'Effortless Control,\nAutomate, & Secure',
    subtitle:
        'Smartify empowers you to control your devices, & automate your routines. Embrace a world where your home adapts to your needs',
  ),
  _WalkthroughPage(
    imagePath: 'assets/images/walkthrough3.png',
    title: 'Efficiency that Saves,\nComfort that Lasts.',
    subtitle:
        "Take control of your home's energy usage, set preferences, and enjoy a space that adapts to your needs while saving power.",
  ),
];

// ─── WalkthroughScreen ───────────────────────────────────────────────────────
class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key, this.onFinished});
  final VoidCallback? onFinished;

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _dotInactive = Color(0xFFD9D9D9);

  void _goToNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToWelcome();
    }
  }

  void _skip() => _navigateToWelcome();

  void _navigateToWelcome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.57;
    final isLast = _currentIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── TOP: blue area + mockup phone ──────────────────────────────
          SizedBox(
            height: topHeight,
            child: Stack(
              children: [
                // Blue curved background
                ClipPath(
                  clipper: _BottomCurveClipper(),
                  child: Container(
                    width: double.infinity,
                    height: topHeight,
                    color: _primaryBlue,
                  ),
                ),
                // PageView of mockup images
                PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemBuilder: (_, i) => _MockupImage(
                    imagePath: _pages[i].imagePath,
                    topHeight: topHeight,
                  ),
                ),
              ],
            ),
          ),

          // ── BOTTOM: white area ──────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
              child: Column(
                children: [
                  // Title
                  Text(
                    _pages[_currentIndex].title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0D0D0D),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Subtitle
                  Text(
                    _pages[_currentIndex].subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B6B6B),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = i == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isActive ? _primaryBlue : _dotInactive,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  // Buttons
                  isLast ? _getStartedButton() : _skipContinueButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _skip,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Text(
          "Let's Get Started",
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _skipContinueButtons() {
    return Row(
      children: [
        // Skip button
        Expanded(
          child: SizedBox(
            height: 58,
            child: TextButton(
              onPressed: _skip,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEEEEF5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Text(
                'Skip',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Continue button
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 58,
            child: ElevatedButton(
              onPressed: _goToNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: Text(
                'Continue',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Mockup image widget ─────────────────────────────────────────────────────
class _MockupImage extends StatelessWidget {
  final String imagePath;
  final double topHeight;

  const _MockupImage({required this.imagePath, required this.topHeight});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: topHeight * 0.93,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

// ─── Clipper để tạo đường cong phía dưới của vùng xanh ──────────────────────
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
