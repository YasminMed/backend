import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/constants/app_text_styles.dart';
import 'package:skillora/models/course_model.dart';
import 'package:skillora/providers/course_provider.dart';
import 'package:skillora/screens/study/course_detail_screen.dart';
import 'package:skillora/providers/auth_provider.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  String selectedFilter = "All";
  final filters = ["All", "Completed", "In Progress", "Easy", "Medium", "Hard"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
    });
  }

  List<Course> _getFilteredCourses(List<Course> courses) {
    switch (selectedFilter) {
      case "Completed":
        return courses.where((c) => c.progress == 100).toList();
      case "In Progress":
        return courses.where((c) => c.progress < 100).toList();
      case "Easy":
      case "Medium":
      case "Hard":
        return courses.where((c) => c.difficulty == selectedFilter).toList();
      default:
        return courses;
    }
  }

  Color difficultyColor(String diff) {
    switch (diff) {
      case "Easy":
        return AppColors.softGreen;
      case "Medium":
        return AppColors.accent;
      case "Hard":
        return Colors.redAccent;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final takenCourses = _getFilteredCourses(provider.takenCourses);
        final availableCourses = provider.availableCourses;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      AppColors.getBackgroundColor(context),
                      AppColors.getBackgroundColor(context),
                    ]
                  : [
                      AppColors.getSurfaceColor(context),
                      AppColors.softGreen.withValues(alpha: 0.05),
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                //App Bar
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.getMainColor(context),
                        AppColors.accent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getMainColor(context).withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Center(
                    child: Text(
                      'Courses',
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: provider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => provider.fetchCourses(),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle("Taken Courses"),
                                SizedBox(height: 8),
                                _filters(),
                                SizedBox(height: 16),
                                if (takenCourses.isEmpty)
                                  _emptyState("No registered courses yet!")
                                else
                                  ...takenCourses.map(_takenCourseCard),
                                SizedBox(height: 30),
                                _sectionTitle("Available Courses"),
                                SizedBox(height: 12),
                                ...availableCourses.map(_availableCourseCard),
                                SizedBox(height: 20),
                              ],
                            ),
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

  Widget _emptyState(String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(
      child: Text(
        message,
        style: AppTextStyles.body.copyWith(color: AppColors.grey),
      ),
    ),
  );

  Widget _sectionTitle(String title) => Text(
    title,
    style: AppTextStyles.h1.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.getMainColor(context),
    ),
  );

  Widget _filters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: filters.map((f) {
        final active = f == selectedFilter;
        return GestureDetector(
          onTap: () => setState(() => selectedFilter = f),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: active
                  ? LinearGradient(
                      colors: [
                        AppColors.getMainColor(context),
                        AppColors.accent,
                      ],
                    )
                  : null,
              color: active ? null : AppColors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              f,
              style: active
                  ? AppTextStyles.button
                  : AppTextStyles.label.copyWith(
                      color: AppColors.getTextColor(context),
                    ),
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _takenCourseCard(Course c) => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailScreen(course: c)),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.25),
                      AppColors.getMainColor(context).withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(c.icon, color: AppColors.accent, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.title,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: AppColors.grey),
                        SizedBox(width: 4),
                        Text(
                          "${c.hours} hrs",
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(
                          Icons.bolt,
                          size: 16,
                          color: difficultyColor(c.difficulty),
                        ),
                        SizedBox(width: 4),
                        Text(
                          c.difficulty,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),

                    // Progress Bar
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: c.progress / 100,
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
                        SizedBox(width: 8),
                        Text(
                          "${c.progress}%",
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _availableCourseCard(Course c) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(context).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.limeGreen.withValues(alpha: 0.4),
                    AppColors.softGreen.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(c.icon, color: AppColors.accent, size: 24),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.bolt,
                        size: 16,
                        color: difficultyColor(c.difficulty),
                      ),
                      SizedBox(width: 4),
                      Text(
                        c.difficulty,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.schedule, size: 16, color: AppColors.grey),
                      SizedBox(width: 4),
                      Text(
                        c.duration,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                final courseProvider = context.read<CourseProvider>();
                final authProvider = context.read<AuthProvider>();
                
                await courseProvider.registerCourse(c.id);
                await authProvider.registerCourse(c.id);
                
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Registered for ${c.title}")),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.getMainColor(context), AppColors.accent],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: Text(
                  "Register",
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
