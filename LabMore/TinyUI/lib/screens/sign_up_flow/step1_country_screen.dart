import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'step2_home_name_screen.dart';

class Step1CountryScreen extends StatefulWidget {
  const Step1CountryScreen({super.key});

  @override
  State<Step1CountryScreen> createState() => _Step1CountryScreenState();
}

class _Step1CountryScreenState extends State<Step1CountryScreen> {
  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _bgLight = Color(0xFFF5F5F7);
  static const Color _borderColor = Color(0xFFE5E7EB);

  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, String>> _allCountries = [
    {'name': 'Afghanistan', 'flag': '🇦🇫'},
    {'name': 'Albania', 'flag': '🇦🇱'},
    {'name': 'Algeria', 'flag': '🇩🇿'},
    {'name': 'Andorra', 'flag': '🇦🇩'},
    {'name': 'Angola', 'flag': '🇦🇴'},
    {'name': 'United Arab Emirates', 'flag': '🇦🇪'},
    {'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'United States of America', 'flag': '🇺🇸'},
    {'name': 'Vietnam', 'flag': '🇻🇳'},
  ];

  List<Map<String, String>> _filteredCountries = [];
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _filteredCountries = List.from(_allCountries);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = _allCountries
          .where((c) => c['name']!.toLowerCase().contains(query))
          .toList();
    });
  }

  void _skip() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const Step2HomeNameScreen(),
    ));
  }

  void _continue() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const Step2HomeNameScreen(),
    ));
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
                  
                  // Progress bar
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
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _primaryBlue,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const Expanded(flex: 3, child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  
                  // Step count
                  Text(
                    '1 / 4',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Content ──────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 24),

                  // Title
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                        height: 1.3,
                      ),
                      children: const [
                        TextSpan(text: 'Select '),
                        TextSpan(text: 'Country', style: TextStyle(color: _primaryBlue)),
                        TextSpan(text: ' of Origin'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  Text(
                    "Let's start by selecting the country where your smart haven resides.",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: _textGrey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Search Field
                  TextField(
                    controller: _searchController,
                    style: GoogleFonts.inter(fontSize: 15, color: _textDark),
                    decoration: InputDecoration(
                      hintText: 'Search Country...',
                      hintStyle: GoogleFonts.inter(fontSize: 15, color: const Color(0xFFA0A0A0)),
                      filled: true,
                      fillColor: const Color(0xFFFAFAFA),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFA0A0A0), size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                              },
                              child: const Icon(Icons.close, color: _textDark, size: 20),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Country List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCountries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final isSelected = _selectedCountry == country['name'];
                      
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCountry = country['name']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? _primaryBlue : _borderColor,
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
                          child: Row(
                            children: [
                              Text(
                                country['flag']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  country['name']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: _textDark,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check, color: _primaryBlue, size: 20),
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
