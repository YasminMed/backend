import 'package:flutter/material.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/screens/study/study_dashboard_screen.dart';
import 'package:skillora/screens/study/course_list_screen.dart';
import 'package:skillora/screens/study/study_goals_screen.dart';
import 'package:skillora/screens/study/notes_screen.dart';
import 'package:skillora/screens/study/time_line_screen.dart';
import 'student_bottom_navbar.dart';
import 'package:provider/provider.dart';
import 'package:skillora/providers/auth_provider.dart';
import 'package:skillora/providers/course_provider.dart';
import 'package:skillora/providers/goal_provider.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  String activeTab = 'dashboard';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final courses = context.read<CourseProvider>();
      final goals = context.read<GoalProvider>();

      goals.fetchGoals();
      // The provider now automatically handles per-user sync using ProxyProvider
      courses.fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          extendBody: true,
          backgroundColor: AppColors.getBackgroundColor(context),
          body: _buildCurrentScreen(),
          bottomNavigationBar: StudentBottomNavBar(
            activeTab: activeTab,
            onTabChange: (tab) {
              setState(() {
                activeTab = tab;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen() {
    switch (activeTab) {
      case 'dashboard':
        return StudentDashboard();
      case 'courses':
        return CourseListScreen();
      case 'goals':
        return StudentGoalScreen();
      case 'notes':
        return NotesWidget();
      case 'journey':
        return TimelineScreen();
      default:
        return StudentDashboard();
    }
  }
}
