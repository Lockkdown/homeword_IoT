import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'step4_location_screen.dart';

class Step3RoomsScreen extends StatefulWidget {
  const Step3RoomsScreen({super.key});

  @override
  State<Step3RoomsScreen> createState() => _Step3RoomsScreenState();
}

class _Step3RoomsScreenState extends State<Step3RoomsScreen> {
  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _bgLight = Color(0xFFF5F5F7);
  static const Color _cardBg = Color(0xFFFAFAFA);

  // List of rooms based on UI
  final List<Map<String, dynamic>> _roomsData = [
    {'name': 'Living Room', 'icon': Icons.chair_outlined, 'selected': true},
    {'name': 'Bedroom', 'icon': Icons.bed_outlined, 'selected': true},
    {'name': 'Bathroom', 'icon': Icons.bathtub_outlined, 'selected': true},
    {'name': 'Kitchen', 'icon': Icons.countertops_outlined, 'selected': true},
    {'name': 'Study Room', 'icon': Icons.menu_book_outlined, 'selected': false},
    {'name': 'Dining Room', 'icon': Icons.restaurant_outlined, 'selected': true},
    {'name': 'Backyard', 'icon': Icons.park_outlined, 'selected': true},
    {'name': 'Add Room', 'icon': Icons.add_circle_outline, 'selected': false, 'isAddAction': true},
  ];

  void _skip() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const Step4LocationScreen(),
    ));
  }

  void _continue() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const Step4LocationScreen(),
    ));
  }

  void _toggleRoom(int index) {
    if (_roomsData[index]['isAddAction'] == true) {
      // Handle add custom room
      return;
    }
    setState(() {
      _roomsData[index]['selected'] = !_roomsData[index]['selected'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (Appbar + Progress) ──────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 24, bottom: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: _textDark, size: 22),
                  ),
                  const SizedBox(width: 8),

                  // Progress bar (Step 3/4)
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: _bgLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _primaryBlue,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const Expanded(flex: 1, child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Step count
                  Text(
                    '3 / 4',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                          height: 1.3,
                        ),
                        children: const [
                          TextSpan(text: 'Add '),
                          TextSpan(text: 'Rooms', style: TextStyle(color: _primaryBlue)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Center(
                    child: Text(
                      "Select the rooms in your house. Don't worry, you can always add more later.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: _textGrey,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Grid view of rooms
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4, // Ratio equivalent to width/height of the card
                    ),
                    itemCount: _roomsData.length,
                    itemBuilder: (context, index) {
                      final item = _roomsData[index];
                      final bool isSelected = item['selected'] == true;
                      final bool isAddAction = item['isAddAction'] == true;

                      return GestureDetector(
                        onTap: () => _toggleRoom(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : _cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? _primaryBlue : Colors.transparent,
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _primaryBlue.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      item['icon'],
                                      size: 36,
                                      color: isAddAction ? _primaryBlue : _primaryBlue,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      item['name'],
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: _textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected && !isAddAction)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      color: _primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // ── Footer Buttons ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: TextButton(
                        onPressed: _skip,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFEEEEF5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
}
