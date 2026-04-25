import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:skillora/constants/app_colors.dart';

// App Colors
class NavbarColors {
  static const Color primary = Color(0xFFCBDFBD); // Soft Green
  static const Color secondary = Color(0xFFFF6B6B); // Coral Red
  static const Color softGreen = Color(0xFFCBDFBD); // Soft Green
  static const Color lime = Color(0xFFD4E09B); // Lime Green
  static const Color accent = Color(0xFFF19C79); // Warm Orange
  static const Color darkBrown = Color(0xFF6F5E53); // Dark Brown
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFBDBDBD);
}

class NavItem {
  final String id;
  final String label;
  final IconData icon;

  NavItem({required this.id, required this.label, required this.icon});
}

class StudentBottomNavBar extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const StudentBottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final List<NavItem> navItems = [
      NavItem(id: 'dashboard', label: 'Dashboard', icon: Icons.home),
      NavItem(id: 'courses', label: 'Courses', icon: Icons.menu_book),
      NavItem(id: 'goals', label: 'Goals', icon: Icons.track_changes),
      NavItem(id: 'notes', label: 'Notes', icon: Icons.description),
      NavItem(id: 'journey', label: 'Journey', icon: Icons.map),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: false,
        child: UnconstrainedBox(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 360, minWidth: 300),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(context).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: navItems.map((item) {
                      final isActive = activeTab == item.id;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTabChange(item.id),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: isActive ? 48 : 40,
                                height: isActive ? 48 : 40,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.getMainColor(context)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: AppColors.getMainColor(context)
                                                .withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Icon(
                                  item.icon,
                                  size: isActive ? 24 : 22,
                                  color: isActive
                                      ? AppColors.getSurfaceColor(context)
                                      : AppColors.getTextColor(context)
                                          .withValues(alpha: 0.4),
                                ),
                              ),
                              if (isActive)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.getMainColor(context),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
