import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../notifications/notification_screen.dart';
import 'package:skillora/constants/app_colors.dart';
import '../settings/settings_screen.dart';
import 'study_profile_screen.dart';

import 'package:provider/provider.dart';
import 'package:skillora/providers/course_provider.dart';
import 'package:skillora/providers/goal_provider.dart';
import 'package:skillora/models/course_model.dart' as model;
import 'package:skillora/models/user_model.dart';
import 'package:skillora/providers/auth_provider.dart';
import 'course_detail_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getMainColor(context).withValues(alpha: 
              Theme.of(context).brightness == Brightness.dark ? 0.0 : 0.05,
            ),
            AppColors.getBackgroundColor(context),
            AppColors.accent.withValues(alpha: 
              Theme.of(context).brightness == Brightness.dark ? 0.0 : 0.05,
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Consumer2<CourseProvider, GoalProvider>(
          builder: (context, courseProvider, goalProvider, child) {
            final takenCourses = courseProvider.takenCourses;
            final completedCourses = takenCourses.where((c) => c.progress == 100).length;
            final completedGoals = goalProvider.goals.where((g) => g.isCompleted).length;
            
            // Aggregate study hours
            final totalStudyHours = takenCourses.fold<double>(0.0, (sum, c) => sum + c.hours);

            // Dashboard progress: 3% per completed week, 3% per goal
            int totalCompletedWeeks = takenCourses.fold(0, (sum, c) => sum + c.completedWeeks.where((w) => w).length);
            double dashboardPercentage = (totalCompletedWeeks * 3.0) + (completedGoals * 3.0);
            if (dashboardPercentage > 100) dashboardPercentage = 100;

            return Column(
              children: [
                const AppBarWidget(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        StudyProgressWidget(
                          percentage: dashboardPercentage,
                          weeklyHours: totalStudyHours,
                          completedCoursesCount: completedCourses,
                          totalRegisteredCourses: takenCourses.length,
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        const RecentCoursesWidget(),
                        const SizedBox(height: 16),
                        const PeopleYouMayKnowWidget(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

//appbar
class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userModel = authProvider.currentUserModel;
    final displayEmail = userModel?.email ?? 'Guest';
    final initial = displayEmail.isNotEmpty
        ? displayEmail[0].toUpperCase()
        : 'G';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.getSurfaceColor(context)
            : null,
        gradient: Theme.of(context).brightness == Brightness.dark
            ? null
            : LinearGradient(
                colors: [AppColors.getMainColor(context), AppColors.accent],
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/student_profile');
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: AppColors.getMainColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userModel?.name ?? 'User',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.getMainColor(context)
                              : AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        displayEmail,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationScreen()),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// circular progress painter
class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color activeColor;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.percentage,
    required this.activeColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * (percentage / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

//circular progress widget

class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? activeColor;
  final Color backgroundColor;
  final String label;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    this.activeColor,
    this.backgroundColor = AppColors.white,
    this.label = 'Complete',
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.getMainColor(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: CircularProgressPainter(
              percentage: progress,
              activeColor: effectiveActiveColor,
              backgroundColor: backgroundColor,
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${progress.toInt()}%',
                style: TextStyle(
                  color: effectiveActiveColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: effectiveActiveColor.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StudyProgressWidget extends StatelessWidget {
  final double percentage;
  final double weeklyHours;
  final int completedCoursesCount;
  final int totalRegisteredCourses;

  const StudyProgressWidget({
    super.key,
    required this.percentage,
    required this.weeklyHours,
    required this.completedCoursesCount,
    required this.totalRegisteredCourses,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Study Progress',
                style: TextStyle(
                  color: AppColors.getMainColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: CircularProgressWidget(
                  progress: percentage,
                  label: 'Complete',
                  activeColor: AppColors.getMainColor(context),
                ),
              ),
              const SizedBox(height: 14),
              _buildStatCard(
                context,
                icon: Icons.access_time,
                label: 'Weekly Study Hours',
                value: '${weeklyHours.toStringAsFixed(1)} hrs',
              ),
              const SizedBox(height: 10),
              _buildStatCard(
                context,
                icon: Icons.assignment_turned_in,
                label: 'Completed Courses',
                value: '$completedCoursesCount/$totalRegisteredCourses',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(color: AppColors.black.withValues(alpha: 0.03), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.getMainColor(context)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(icon, color: AppColors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        color: AppColors.getMainColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Course {
  final String title;
  final int progress;
  final IconData icon;

  Course({required this.title, required this.progress, required this.icon});
}

class RecentCoursesWidget extends StatelessWidget {
  const RecentCoursesWidget({super.key});

  static final List<Course> courses = [
    Course(
      title: 'Web Development Fundamentals',
      progress: 75,
      icon: Icons.code,
    ),
    Course(title: 'UI/UX Design Principles', progress: 45, icon: Icons.palette),
    Course(
      title: 'Data Structures & Algorithms',
      progress: 60,
      icon: Icons.psychology,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final takenCourses = provider.takenCourses;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Courses',
              style: TextStyle(
                color: AppColors.getMainColor(context),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            if (takenCourses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No registered courses yet!',
                    style: TextStyle(color: AppColors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              ...takenCourses.map(
                (course) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildCourseCard(context, course),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCourseCard(BuildContext context, model.Course course) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 20),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.2),
                      AppColors.accent.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(course.icon, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: course.progress / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.getMainColor(context),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${course.progress}%',
                        style: TextStyle(
                          color: AppColors.getMainColor(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailScreen(course: course),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.getMainColor(context), AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getMainColor(context).withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LearningPath {
  final String title;
  final String description;
  final IconData icon;
  final bool isHighlighted;

  LearningPath({
    required this.title,
    required this.description,
    required this.icon,
    this.isHighlighted = false,
  });
}

class SuggestedLearningPathsWidget extends StatelessWidget {
  const SuggestedLearningPathsWidget({super.key});

  static final List<LearningPath> paths = [
    LearningPath(
      title: 'Full Stack Developer',
      description:
          'Master frontend and backend development with modern frameworks',
      icon: Icons.rocket_launch,
      isHighlighted: true,
    ),
    LearningPath(
      title: 'UX/UI Designer',
      description: 'Learn design thinking and create amazing user experiences',
      icon: Icons.star,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggested Learning Paths',
          style: TextStyle(
            color: AppColors.getMainColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...paths.map(
          (path) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildPathCard(context, path),
          ),
        ),
      ],
    );
  }

  Widget _buildPathCard(BuildContext context, LearningPath path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 20,
              ),
            ],
          ),
          child: Stack(
            children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.limeGreen.withValues(alpha: 0.3),
                      AppColors.softGreen.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.limeGreen.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Icon(path.icon, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      path.title,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      path.description,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent,
                            AppColors.getMainColor(context),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Start Now',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (path.isHighlighted)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.getMainColor(context), AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
    ),
    );
  }
}

// people u may know
class Person {
  final String name;
  final String field;
  final String initials;

  Person({required this.name, required this.field, required this.initials});
}

class PeopleYouMayKnowWidget extends StatelessWidget {
  const PeopleYouMayKnowWidget({super.key});

  static final List<List<Color>> avatarGradients = [
    [AppColors.primary, AppColors.accent],
    [AppColors.accent, AppColors.softGreen],
    [AppColors.softGreen, AppColors.limeGreen],
    [AppColors.limeGreen, AppColors.primary],
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'People You May Know',
          style: TextStyle(
            color: AppColors.getMainColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<UserModel>>(
          future: authProvider.getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    "No more users to connect with",
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),
              );
            }

            final users = snapshot.data!;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return _buildUserCard(context, users[index], index);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user, int index) {
    String initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : "?";

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      avatarGradients[index % avatarGradients.length][0] ==
                              AppColors.primary
                          ? AppColors.getMainColor(context)
                          : avatarGradients[index % avatarGradients.length][0],
                      avatarGradients[index % avatarGradients.length][1] ==
                              AppColors.primary
                          ? AppColors.getMainColor(context)
                          : avatarGradients[index % avatarGradients.length][1],
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user.name,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.white
                      : AppColors.black.withValues(alpha: 0.87),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user.email,
                style: const TextStyle(color: AppColors.grey, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudyProfileWidget(userId: user.uid),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.getMainColor(context), AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getMainColor(context).withValues(alpha: 0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
