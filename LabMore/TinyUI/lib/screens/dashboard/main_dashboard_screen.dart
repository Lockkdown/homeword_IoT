import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'add_device_screen.dart';
import 'chatbot_screen.dart';
import 'notification_screen.dart';
import 'voice_assistant_screen.dart';
import '../../services/device_manager.dart';
import '../../services/mqtt_service.dart';
import 'control_device_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  static const Color _primaryBlue = Color(0xFF536DFE);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _bgLight = Color(0xFFFAFAFA);

  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    'All Rooms',
    'Living Room',
    'Bedroom',
    'Kitchen',
  ];

  int _bottomNavIndex = 0;
  final DeviceManager _deviceManager = DeviceManager();

  @override
  void initState() {
    super.initState();
    _deviceManager.init();
    // Connect MQTT sau khi đã đăng nhập thành công
    // Tách biệt với login để MQTT error không ảnh hưởng login
    _connectMqttSilently();
  }

  void _connectMqttSilently() {
    // Fire-and-forget: không await, không throw
    MqttService().connect().then((connected) {
      debugPrint('[Dashboard] MQTT connected: $connected');
    }).catchError((e) {
      debugPrint('[Dashboard] MQTT connect failed (suppressed): $e');
    });
  }

  void _navigateToAddDevice() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddDeviceScreen()));
  }

  void _showAddOptions() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6), // Sập tối
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Làm mờ
          child: Material(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 100, left: 24, right: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add Options',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildOptionItem(
                      icon: Icons.add_circle_outline,
                      title: 'Add Device',
                      subtitle: 'Add a new smart device to your home',
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToAddDevice();
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: Color(0xFFEEEEF5)),
                    ),
                    _buildOptionItem(
                      icon: Icons.room_preferences_outlined,
                      title: 'Add Room',
                      subtitle: 'Create a new room in your home',
                      onTap: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _primaryBlue, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFD4D4D8)),
          ],
        ),
      ),
    );
  }

  void _showHomeSwitcher() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  top: 90,
                  left: 24,
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHomeMenuItem('My Home', isSelected: true),
                        _buildHomeMenuItem('My Apartment'),
                        _buildHomeMenuItem('My Office'),
                        _buildHomeMenuItem('My Parents\' House'),
                        _buildHomeMenuItem('My Garden'),
                        const Divider(height: 1, color: Color(0xFFEEEEF5)),
                        _buildHomeMenuItem(
                          'Home Management',
                          icon: Icons.settings_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeMenuItem(String title, {bool isSelected = false, IconData? icon}) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: _textDark, size: 22),
              const SizedBox(width: 16),
            ] else if (isSelected) ...[
              const Icon(Icons.check, color: _primaryBlue, size: 22),
              const SizedBox(width: 16),
            ] else ...[
              const SizedBox(width: 38), // Space placeholder to align text
            ],
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Appbar ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
                      InkWell(
                        onTap: _showHomeSwitcher,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                          child: Row(
                            children: [
                              Text(
                                'My Home',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: _textDark,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Icons right
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ChatBotScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _primaryBlue.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.smart_toy_outlined,
                                  color: _primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFEEEEF5),
                                  width: 1.5,
                                ),
                                color: _bgLight,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.notifications_none_rounded,
                                    color: _textDark,
                                    size: 24,
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 12,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF5252),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Content ────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // 1. Weather Widget Full Width Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildWeatherCard(),
                        ),
                        const SizedBox(height: 32),

                        // 2. All Devices Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ValueListenableBuilder<List<DeviceModel>>(
                                valueListenable: _deviceManager.devices,
                                builder: (context, devices, child) {
                                  return Text(
                                    'All Devices (${devices.length})',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                  );
                                },
                              ),
                              const Icon(
                                Icons.more_vert_rounded,
                                color: _textDark,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // All Devices Grid
                        ValueListenableBuilder<List<DeviceModel>>(
                          valueListenable: _deviceManager.devices,
                          builder: (context, devices, child) {
                            if (devices.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: _bgLight,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.devices_other_outlined,
                                        size: 48,
                                        color: _textGrey,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No devices added yet',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _textGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _navigateToAddDevice,
                                        child: Text(
                                          'Add Device',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: devices.length,
                                itemBuilder: (context, index) {
                                  final device = devices[index];
                                  return _buildDeviceCard(
                                    device: device,
                                    onToggle: () => _deviceManager.toggleDevice(device.id),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ControlDeviceScreen(device: device),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // 3. Horizontal Filter Chips
                        SizedBox(
                          height: 38,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _filters.length,
                            itemBuilder: (context, index) {
                              bool isSelected = index == _selectedFilterIndex;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: InkWell(
                                  onTap: () => setState(
                                    () => _selectedFilterIndex = index,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _primaryBlue
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? _primaryBlue
                                            : const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _filters[index],
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : _textDark,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 4. Empty State (No Devices)
                        Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              // Clipboard Icon Illustration (Using built-in placeholder or custom stack)
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color: _textGrey.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Icon(
                                    Icons.content_paste_rounded,
                                    color: _primaryBlue.withValues(alpha: 0.8),
                                    size: 70,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              Text(
                                'No Devices',
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "You haven't added a device yet.",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: _textGrey,
                                ),
                              ),
                              const SizedBox(height: 32),

                              ElevatedButton.icon(
                                onPressed: _navigateToAddDevice,
                                icon: const Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Add Device',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 120,
                              ), // Padding for bottom FABs
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Floating Action Buttons (Mic & Add) ────────────────
            Positioned(
              bottom: 24,
              right: 24,
              child: Row(
                children: [
                  FloatingActionButton(
                    heroTag: 'mic',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VoiceAssistantScreen(),
                          fullscreenDialog: true,
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFFF0F4FF),
                    elevation: 0,
                    child: const Icon(
                      Icons.mic_none_rounded,
                      color: _primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  FloatingActionButton(
                    heroTag: 'add',
                    onPressed: _showAddOptions,
                    backgroundColor: _primaryBlue,
                    elevation: 4,
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (idx) => setState(() => _bottomNavIndex = idx),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: _primaryBlue,
          unselectedItemColor: const Color(0xFFA0A0A0),
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          iconSize: 26,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Icon(Icons.home_filled),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Icon(Icons.check_box_outlined),
              ),
              label: 'Smart',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Icon(Icons.show_chart_rounded),
              ),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Icon(Icons.person_outline_rounded),
              ),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5A75FF), Color(0xFF3B56E6)],
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background geometric patterns (optional subtle waves)
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '20',
                            style: GoogleFonts.inter(
                              fontSize: 64,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '°C',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'New York City, USA',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Today Cloudy',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Small info row
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildSmallInfo(Icons.eco_outlined, 'AQI 92'),
                          _buildSmallInfo(Icons.water_drop_outlined, '78.2%'),
                          _buildSmallInfo(Icons.air_outlined, '2.0 m/s'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Big Cloud/Sun Illustration Side
                // We use standard Flutter icons wrapped in a nice UI as a fallback for the large weather graphic
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      right: 10,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFB300),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, right: 10),
                      child: Icon(
                        Icons.cloud_rounded,
                        color: Colors.white,
                        size: 100,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceCard({
    required DeviceModel device,
    required VoidCallback onToggle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: device.isOn ? const Color(0xFFFFB800) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: device.isOn ? Colors.white : _textGrey,
                    size: 24,
                  ),
                ),
                Switch(
                  value: device.isOn,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: _primaryBlue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              device.name,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.wifi_outlined,
                  size: 14,
                  color: _textGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  device.ssid ?? 'Offline',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _textGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
