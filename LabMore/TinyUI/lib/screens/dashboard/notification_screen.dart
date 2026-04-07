import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color _primaryBlue = Color(0xFF3B56E6);
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _bgLight = Color(0xFFF0F4FF); // Placeholder light blue

  bool isGeneralTab = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: _textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7), // Light grey background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isGeneralTab = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isGeneralTab ? _primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'General',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isGeneralTab ? Colors.white : _textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => isGeneralTab = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isGeneralTab ? _primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Smart Home',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: !isGeneralTab ? Colors.white : _textDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Notification List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildDateSeparator('Today'),
                _buildNotificationItem(
                  icon: Icons.shield_outlined,
                  title: 'Account Security Alert',
                  iconBadge: Icons.lock_outline,
                  iconBadgeColor: const Color(0xFFB5A642),
                  message:
                      "We've noticed some unusual activity on your account. Please review your recent logins and update your password if necessary.",
                  time: '09:41 AM',
                  isUnread: true,
                ),
                _buildNotificationItem(
                  icon: Icons.info_outline,
                  title: 'System Update Available',
                  iconBadge: Icons.loop,
                  iconBadgeColor: const Color(0xFF6B7280),
                  message:
                      "A new system update is ready for installation. It includes performance improvements and bug fixes.",
                  time: '08:46 AM',
                  isUnread: true,
                ),
                _buildDateSeparator('Yesterday'),
                _buildNotificationItem(
                  icon: Icons.lock_outline,
                  title: 'Password Reset Successful',
                  iconBadge: Icons.check_box,
                  iconBadgeColor: Colors.green,
                  message:
                      "Your password has been successfully reset. If you didn't request this change, please contact support immediately.",
                  time: '20:30 PM',
                  isUnread: false,
                ),
                _buildNotificationItem(
                  icon: Icons.star_border,
                  title: 'Exciting New Feature',
                  iconBadge: Icons.new_releases, // Placeholder for 'NEW' badge
                  iconBadgeColor: const Color(0xFF6284B9),
                  message:
                      "We've just launched a new feature that will enhance your user experience. Check it out now!",
                  time: '16:29 PM',
                  isUnread: false,
                ),
                _buildNotificationItem(
                  icon: Icons.event, // Placeholder
                  title: 'Event Reminder',
                  iconBadge: Icons.calendar_today,
                  iconBadgeColor: Colors.red,
                  message: "Remind you of an upcoming event...", // Placeholder message
                  time: '',
                  isUnread: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            date,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFFEEEEF5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    IconData? iconBadge,
    Color? iconBadgeColor,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEEEF5), width: 1.5),
            ),
            child: Icon(icon, color: _textDark, size: 24),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (iconBadge != null) ...[
                            const SizedBox(width: 4),
                            Icon(iconBadge, size: 16, color: iconBadgeColor),
                          ],
                        ],
                      ),
                    ),
                    if (isUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFD4D4D8),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _textGrey,
                    height: 1.4,
                  ),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _textGrey,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
