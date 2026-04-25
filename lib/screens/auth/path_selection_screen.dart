import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/constants/app_text_styles.dart';
import 'package:skillora/providers/theme_provider.dart';
import 'package:skillora/providers/auth_provider.dart';
import 'package:skillora/services/notification_service.dart';

class PathSelectionScreen extends StatefulWidget {
  const PathSelectionScreen({super.key});

  @override
  State<PathSelectionScreen> createState() => _PathSelectionScreenState();
}

class _PathSelectionScreenState extends State<PathSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.getBackgroundColor(context),
              AppColors.getBackgroundColor(context).withValues(alpha: 0.95),
              AppColors.getSurfaceColor(context).withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 393),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Choose Your Path',
                      style: AppTextStyles.h1.copyWith(
                        height: 1.2,
                        color: AppColors.getTextColor(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select the journey you want to explore',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.getTextColor(context).withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    _PathCard(
                      title: 'Study Path',
                      description: 'Plan and track your academic journey',
                      icon: Icons.school,
                      gradientColors: const [Color(0xFFFF6B6B), Color(0xFFF19C79)],
                      onTap: () async {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        await auth.setUserRole('student');
                        
                        if (context.mounted) {
                          Provider.of<ThemeProvider>(
                            context,
                            listen: false,
                          ).setPath(AppPath.study);
                          
                          // Schedule notifications
                          final theme = Provider.of<ThemeProvider>(context, listen: false);
                          NotificationService().schedulePeriodicNotifications(
                            'student', 
                            theme.notificationsEnabled,
                          );
                          
                          Navigator.pushNamed(context, '/student_main');
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    _PathCard(
                      title: 'Career Path',
                      description: 'Build and grow your professional future',
                      icon: Icons.work,
                      gradientColors: const [
                        Color.fromARGB(255, 147, 163, 68),
                        Color.fromARGB(255, 192, 231, 164),
                      ],
                      onTap: () async {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        await auth.setUserRole('worker');
                        
                        if (context.mounted) {
                          Provider.of<ThemeProvider>(
                            context,
                            listen: false,
                          ).setPath(AppPath.career);
                          
                          // Schedule notifications
                          final theme = Provider.of<ThemeProvider>(context, listen: false);
                          NotificationService().schedulePeriodicNotifications(
                            'worker', 
                            theme.notificationsEnabled,
                          );
                          
                          Navigator.pushNamed(context, '/career_main');
                        }
                      },
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'You can switch paths anytime in settings',
                      style: AppTextStyles.tiny.copyWith(
                        color: AppColors.getTextColor(context).withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PathCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _PathCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_PathCard> createState() => _PathCardState();
}

class _PathCardState extends State<_PathCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.gradientColors
                .map((color) => color.withValues(alpha: 0.9))
                .toList(),
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.gradientColors[0].withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.gradientColors[0].withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.white.withValues(alpha: 0.3),
                              AppColors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.white.withValues(alpha: 0.3),
                              AppColors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(widget.icon, size: 32, color: AppColors.white),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.arrow_forward, color: Colors.white, size: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
