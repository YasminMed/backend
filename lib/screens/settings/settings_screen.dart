import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import 'info_content_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.getMainColor(context), AppColors.accent],
            ),
          ),
        ),
        title: Text(
          'Settings',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.getMainColor(
                context,
              ).withValues(alpha: isDarkMode ? 0.05 : 0.15),
              isDarkMode ? const Color(0xFF121212) : AppColors.white,
              AppColors.accent.withValues(alpha: isDarkMode ? 0.05 : 0.10),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader('Account Settings', isDarkMode),
            const SizedBox(height: 12),
            _buildSectionHeader('Preferences', isDarkMode),
            _buildSettingItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              isDarkMode: isDarkMode,
              trailing: Switch(
                value: isDarkMode,
                onChanged: (val) {
                  themeProvider.toggleTheme();
                },
                thumbColor: WidgetStatePropertyAll(AppColors.getMainColor(context)),
              ),
            ),
            _buildSettingItem(
              icon: Icons.notifications_active_outlined,
              title: 'Enable Notifications',
              isDarkMode: isDarkMode,
              trailing: Switch(
                value: themeProvider.notificationsEnabled,
                onChanged: (val) {
                  themeProvider.toggleNotifications();
                  
                  // Reschedule or cancel notifications
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final role = auth.currentUserModel?.role ?? 'student';
                  NotificationService().schedulePeriodicNotifications(role, val);
                },
                thumbColor: WidgetStatePropertyAll(AppColors.getMainColor(context)),
              ),
            ),
            _buildSettingItem(
              icon: Icons.language,
              title: 'Language',
              isDarkMode: isDarkMode,
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLanguage,
                  dropdownColor: isDarkMode
                      ? const Color(0xFF1E1E1E)
                      : AppColors.white,
                  style: AppTextStyles.body.copyWith(
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                  items: ['English', 'Arabic', 'French'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedLanguage = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Support & About', isDarkMode),
            _buildInfoItem(
              Icons.info_outline,
              'About Us',
              isDarkMode,
              onTap: () => _navigateToInfo(
                context,
                'About Us',
                'Skillora is an innovative educational platform designed to empower students on their professional and academic journeys. Our mission is to provide high-quality, accessible, and interactive learning experiences in cutting-edge fields such as Machine Learning, Cybersecurity, and Graphic Design. We believe in practical, project-based learning that prepares you for real-world challenges.',
              ),
            ),
            _buildInfoItem(
              Icons.mail_outline,
              'Contact Us',
              isDarkMode,
              onTap: () => _navigateToInfo(
                context,
                'Contact Us',
                'Have questions or feedback? We\'d love to hear from you!\n\nEmail: support@skillora.edu\nPhone: +1 (555) 123-4567\nAddress: 123 Education Lane, Tech City, Innovation State\n\nOur support team is available Monday through Friday, 9:00 AM to 6:00 PM.',
              ),
            ),
            _buildInfoItem(
              Icons.privacy_tip_outlined,
              'Privacy Policy',
              isDarkMode,
              onTap: () => _navigateToInfo(
                context,
                'Privacy Policy',
                'Your privacy is important to us. Skillora is committed to protecting your personal information. We collect data solely to provide and improve our services, handle course registrations, and personalize your learning experience. We do not sell your data to third parties. For more details on how we handle your information, please visit our website.',
              ),
            ),
            _buildInfoItem(
              Icons.description_outlined,
              'Terms of Service',
              isDarkMode,
              onTap: () => _navigateToInfo(
                context,
                'Terms of Service',
                'By using Skillora, you agree to our Terms of Service. Users are responsible for maintaining the confidentiality of their accounts and for all activities that occur under their credentials. Skillora reserves the right to update course content and platform features to ensure the best learning experience. Use of the platform for illegal or unauthorized purposes is strictly prohibited.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToInfo(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InfoContentScreen(title: title, content: content),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: AppTextStyles.h2.copyWith(
          color: AppColors.getMainColor(context),
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Widget trailing,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black26
                : AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.getMainColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.getMainColor(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.button.copyWith(
                    color: isDarkMode ? AppColors.white : AppColors.black,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, bool isDarkMode, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black26
                : AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.button.copyWith(
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDarkMode ? Colors.white54 : AppColors.grey,
        ),
        onTap: onTap,
      ),
    );
  }


}
