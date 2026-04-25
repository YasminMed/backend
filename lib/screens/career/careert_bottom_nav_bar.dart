import 'package:flutter/material.dart';
import 'package:skillora/constants/app_colors.dart';

class NavItem {
  final String id;
  final String label;
  final IconData icon;

  NavItem({required this.id, required this.label, required this.icon});
}

class CareerBottomNavBar extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const CareerBottomNavBar({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final List<NavItem> navItems = [
      NavItem(id: 'dashboard', label: 'Dashboard', icon: Icons.dashboard),
      NavItem(id: 'jobs', label: 'Jobs', icon: Icons.work),
      NavItem(id: 'portfolio', label: 'Portfolio', icon: Icons.folder),
      NavItem(id: 'chatbot', label: 'AI Chat', icon: Icons.smart_toy_outlined),
      NavItem(id: 'roadmap', label: 'Roadmap', icon: Icons.route),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.getBackgroundColor(context)
            : AppColors.getSurfaceColor(context),
        border: Border(
          top: BorderSide(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white)
                        : Colors.black)
                    .withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 12,
            right: 12,
            top: 6,
            bottom: 10,
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 330),
            decoration: BoxDecoration(
              color: AppColors.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.map((item) {
                final isActive = activeTab == item.id;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChange(item.id),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: Container(
                        width: isActive ? 50 : 36,
                        height: isActive ? 50 : 36,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.getMainColor(context)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          size: isActive ? 26 : 22,
                          color: isActive
                              ? Colors.white
                              : Colors.grey.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
