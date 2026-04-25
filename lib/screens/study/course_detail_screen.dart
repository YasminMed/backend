import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/constants/app_text_styles.dart';
import 'package:skillora/models/course_model.dart';
import 'package:skillora/providers/course_provider.dart';
import 'package:skillora/providers/auth_provider.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColors.getMainColor(context);
    final pinkColor = AppColors.getMainColor(context);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero App Bar
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: mainColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [mainColor, AppColors.accent],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            course.icon,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          course.title,
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _chip(Icons.timer, course.duration),
                            const SizedBox(width: 10),
                            _chip(
                              Icons.signal_cellular_alt,
                              course.difficulty,
                              color: _difficultyColor(course.difficulty),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Progress Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Consumer<CourseProvider>(
                builder: (context, provider, child) {
                  // Find the current version of the course from provider to get latest progress
                  final currentCourse = provider.takenCourses
                          .where((c) => c.id == course.id)
                          .firstOrNull ??
                      course;

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: Theme.of(context).brightness == Brightness.dark
                            ? [
                                AppColors.getSurfaceColor(context),
                                AppColors.getSurfaceColor(context),
                              ]
                            : [
                                AppColors.getSurfaceColor(context),
                                pinkColor.withValues(alpha: 0.05),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: pinkColor.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
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
                            Text(
                              'Your Progress',
                              style:
                                  AppTextStyles.button.copyWith(fontSize: 16),
                            ),
                            Text(
                              '${currentCourse.progress}%',
                              style: AppTextStyles.h2.copyWith(
                                color: pinkColor,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: currentCourse.progress / 100,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            color: pinkColor,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: AppColors.grey),
                            const SizedBox(width: 6),
                            Text(
                              '${currentCourse.completedWeeks.where((w) => w).length} / ${currentCourse.totalWeeks} weeks completed',
                              style: AppTextStyles.small
                                  .copyWith(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Course Content Sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                'Weekly Content',
                style: AppTextStyles.h2.copyWith(fontSize: 20),
              ),
            ),
          ),

          Consumer<CourseProvider>(
            builder: (context, provider, child) {
              final currentCourse = provider.takenCourses
                      .where((c) => c.id == course.id)
                      .firstOrNull ??
                  course;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final isCompleted = currentCourse.completedWeeks[index];
                    return WeekContentSection(
                      course: currentCourse,
                      weekIndex: index,
                      isCompleted: isCompleted,
                    );
                  },
                  childCount: currentCourse.totalWeeks,
                ),
              );
            },
          ),

          // Delete Course Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
              child: _buildDeleteButton(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, {Color? color}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color ?? Colors.white),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Color _difficultyColor(String diff) {
    switch (diff) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final courseProvider = context.read<CourseProvider>();
        final authProvider = context.read<AuthProvider>();
        
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.getSurfaceColor(context),
            title: Text('Remove Course', style: AppTextStyles.h2),
            content: Text(
              'Are you sure you want to remove "\${course.title}" from your registered courses?',
              style: AppTextStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.button.copyWith(color: AppColors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: Text(
                  'Remove',
                  style: AppTextStyles.button.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        );
 
        if (confirmed == true) {
          await courseProvider.unregisterCourse(course.id);
          await authProvider.unregisterCourse(course.id);
          
          if (context.mounted) Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Delete Course',
              style: AppTextStyles.button.copyWith(
                color: Colors.redAccent,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeekContentSection extends StatefulWidget {
  final Course course;
  final int weekIndex;
  final bool isCompleted;

  const WeekContentSection({
    super.key,
    required this.course,
    required this.weekIndex,
    required this.isCompleted,
  });

  @override
  State<WeekContentSection> createState() => _WeekContentSectionState();
}

class _WeekContentSectionState extends State<WeekContentSection> {
  bool _localCompleted = false;

  @override
  void initState() {
    super.initState();
    _localCompleted = widget.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFFF4081);
    final mainColor = AppColors.getMainColor(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _localCompleted
              ? pinkColor.withValues(alpha: 0.3)
              : mainColor.withValues(alpha: 0.1),
          width: _localCompleted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Checkbox(
            value: _localCompleted,
            activeColor: AppColors.getMainColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _localCompleted = value;
                });
                context.read<CourseProvider>().updateCourseProgress(
                      widget.course.id,
                      widget.weekIndex,
                      value,
                      context.read<AuthProvider>(),
                    );
              }
            },
          ),
          title: Text(
            'Week ${widget.weekIndex + 1}',
            style: AppTextStyles.button.copyWith(
              fontSize: 15,
              color: _localCompleted ? pinkColor : null,
            ),
          ),
          subtitle: Text(
            _localCompleted ? 'Completed' : 'Tap to read more',
            style: AppTextStyles.tiny.copyWith(
              color: _localCompleted
                  ? AppColors.getMainColor(context).withValues(alpha: 0.7)
                  : AppColors.grey,
              fontSize: 11,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                color: (_localCompleted ? pinkColor : mainColor).withValues(alpha: 0.1),
                height: 1,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                  _getWeekContent(),
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.getTextColor(context).withValues(alpha: 0.8),
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _getWeekContent() {
    if (widget.weekIndex < widget.course.weekContents.length) {
      final content = widget.course.weekContents[widget.weekIndex];
      if (content.isNotEmpty) {
        return content;
      }
    }
    return _getFallbackParagraph(widget.weekIndex);
  }

  String _getFallbackParagraph(int week) {
    return "This is the comprehensive content for Week ${week + 1} of ${widget.course.title}. In this module, we delve deep into the core principles and advanced techniques required to master this subject. "
        "The curriculum is designed to challenge your understanding and encourage critical thinking. "
        "As you progress through this text, you will encounter various use cases, theoretical frameworks, and practical applications that are essential for real-world scenarios.\n\n"
        "Make sure to scroll down to the bottom to mark this week as completed!";
  }
}
