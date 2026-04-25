import 'package:flutter/material.dart';
import '../notifications/notification_screen.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/constants/app_text_styles.dart';
import 'package:skillora/screens/settings/settings_screen.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:skillora/providers/milestone_provider.dart';
import 'package:skillora/providers/activity_provider.dart';
import 'package:skillora/providers/auth_provider.dart';
import 'package:skillora/models/user_model.dart';
import 'package:skillora/screens/career/career_profile_screen.dart';
import 'package:skillora/providers/career_nav_provider.dart';

class CareerDashboardWidget extends StatefulWidget {
  const CareerDashboardWidget({super.key});

  @override
  State<CareerDashboardWidget> createState() => _CareerDashboardWidgetState();
}

class _CareerDashboardWidgetState extends State<CareerDashboardWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch milestones and activities when the dashboard is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MilestoneProvider>().fetchMilestones();
      context.read<ActivityProvider>().fetchActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: context.read<MilestoneProvider>()),
        ChangeNotifierProvider.value(value: context.read<ActivityProvider>()),
      ],
      child: Consumer2<MilestoneProvider, ActivityProvider>(
        builder: (context, milestoneProvider, activityProvider, child) {
          final completed = milestoneProvider.completedCount;
          final total = milestoneProvider.milestones.length;
          final xp = milestoneProvider.totalXP;
          final rank = milestoneProvider.rank;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.getMainColor(context).withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.05
                        : 0.15,
                  ),
                  AppColors.getBackgroundColor(context),
                  AppColors.getAccentColor(context).withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.05
                        : 0.10,
                  ),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const AppBarWidget(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CareerProgressWidget(
                            goalsCompleted: completed,
                            totalGoals: total > 0 ? total : 1,
                            currentLevel: rank,
                            experiencePoints: xp,
                          ),
                          const SizedBox(height: 16),
                          MilestoneSection(
                            milestones: milestoneProvider.milestones,
                          ),
                          const SizedBox(height: 16),
                          const RecentActivitiesWidget(),
                          const SizedBox(height: 20),
                          const PeopleYouKnowWidget(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

//appbar
class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final displayEmail = user?.email ?? 'Guest';
    final initial = displayEmail.isNotEmpty
        ? displayEmail[0].toUpperCase()
        : 'G';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
              : [
                  AppColors.getMainColor(context),
                  AppColors.getSecondaryColor(context),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black54
                : AppColors.getMainColor(context).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/career_profile');
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
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.45,
                ),
                child: Text(
                  displayEmail,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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

//circular progress widget

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

    final backgroundPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

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

class CircularProgressWidget extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color activeColor;
  final Color backgroundColor;
  final String label;

  const CircularProgressWidget({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 10,
    required this.activeColor,
    this.backgroundColor = AppColors.white,
    this.label = 'Complete',
  });

  @override
  Widget build(BuildContext context) {
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
              activeColor: activeColor,
              backgroundColor: backgroundColor,
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label.isNotEmpty ? label : '${progress.toInt()}%',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 24,
                  color: activeColor,
                ),
              ),
              Text(
                'Goals',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.getAccentColor(
                    context,
                  ).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//career progress
class CareerProgressWidget extends StatelessWidget {
  final int goalsCompleted;
  final int totalGoals;
  final String currentLevel;
  final int experiencePoints;

  const CareerProgressWidget({
    super.key,
    required this.goalsCompleted,
    required this.totalGoals,
    required this.currentLevel,
    required this.experiencePoints,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (goalsCompleted / totalGoals * 100).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getSurfaceColor(context),
            AppColors.getAccentColor(context).withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.3),
          width: 1,
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
            'Career Progress',
            style: AppTextStyles.h2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 14),
          Center(
            child: CircularProgressWidget(
              progress: percentage,
              label: '$goalsCompleted/$totalGoals',
              activeColor: AppColors.getMainColor(context),
            ),
          ),
          const SizedBox(height: 14),
          _buildStatCard(
            context,
            icon: Icons.trending_up,
            label: 'Current Level',
            value: '$currentLevel Level',
          ),
          const SizedBox(height: 10),
          _buildStatCard(
            context,
            icon: Icons.stars,
            label: 'Experience Points',
            value: '$experiencePoints XP',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.white.withValues(alpha: 0.8),
            AppColors.white.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.getAccentColor(context),
                  AppColors.getMainColor(context),
                ],
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
                  style: AppTextStyles.small.copyWith(color: AppColors.grey),
                ),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Milestone Section
class MilestoneSection extends StatelessWidget {
  final List<Milestone> milestones;

  const MilestoneSection({super.key, required this.milestones});

  void _showAddMilestoneDialog(BuildContext context) {
    final titleController = TextEditingController();
    final milestoneProvider = context.read<MilestoneProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(dialogContext),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Add New Milestone', style: AppTextStyles.h2),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Mastered Flutter Animations',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                milestoneProvider.addMilestone(titleController.text);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getMainColor(dialogContext),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Add Milestone', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Milestones', style: AppTextStyles.h2.copyWith(fontSize: 20)),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showAddMilestoneDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.getMainColor(
                        context,
                      ).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.getMainColor(context),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${milestones.where((m) => m.isCompleted).length}/${milestones.length}',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.getMainColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (milestones.isEmpty)
          GestureDetector(
            onTap: () => _showAddMilestoneDialog(context),
            child: Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_task,
                    color: AppColors.grey.withValues(alpha: 0.5),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No milestones yet. Tap "+" to add your first one!',
                    style: AppTextStyles.secondary.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: milestones.length,
              itemBuilder: (context, index) {
                return _buildMilestoneCard(context, milestones[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildMilestoneCard(BuildContext context, Milestone milestone) {
    final milestoneProvider = context.read<MilestoneProvider>();

    return GestureDetector(
      onTap: () {
        milestoneProvider.toggleMilestoneStatus(
          milestone.id,
          !milestone.isCompleted,
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: milestone.isCompleted
                ? AppColors.getMainColor(context).withValues(alpha: 0.5)
                : AppColors.grey.withValues(alpha: 0.1),
            width: milestone.isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: milestone.isCompleted
                    ? AppColors.getMainColor(context).withValues(alpha: 0.1)
                    : AppColors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events,
                color: milestone.isCompleted
                    ? AppColors.getMainColor(context)
                    : AppColors.grey.withValues(alpha: 0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              milestone.title,
              style: AppTextStyles.small.copyWith(
                fontWeight: milestone.isCompleted
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: milestone.isCompleted
                    ? AppColors.getTextColor(context)
                    : AppColors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (milestone.isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '+500 XP',
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.softGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Recent activities are now handled by ActivityProvider

class RecentActivitiesWidget extends StatefulWidget {
  const RecentActivitiesWidget({super.key});

  @override
  State<RecentActivitiesWidget> createState() => _RecentActivitiesWidgetState();
}

class _RecentActivitiesWidgetState extends State<RecentActivitiesWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().fetchActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activities = context.watch<ActivityProvider>().activities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activities',
          style: AppTextStyles.h2.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 10),
        if (activities.isEmpty)
          _buildEmptyState('No recent activities yet.')
        else
          ...activities
              .take(5)
              .map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildActivityCard(context, activity),
                ),
              ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
      ),
      child: Center(child: Text(message, style: AppTextStyles.secondary)),
    );
  }

  Widget _buildActivityCard(BuildContext context, CareerActivity activity) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getSurfaceColor(context),
            AppColors.getAccentColor(context).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.softGreen.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.getAccentColor(context).withValues(alpha: 0.2),
                  AppColors.getAccentColor(context).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.getAccentColor(context).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              activity.icon,
              color: AppColors.getAccentColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: AppTextStyles.label.copyWith(fontSize: 15),
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
                          widthFactor: activity.progress / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.getAccentColor(context),
                                  AppColors.getMainColor(context),
                                ],
                              ),
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
                      '${activity.progress}%',
                      style: AppTextStyles.small.copyWith(
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
              final navProvider = context.read<CareerNavProvider>();
              if (activity.title.contains('Skill')) {
                navProvider.setTab('skills');
              } else if (activity.title.contains('Project') ||
                  activity.title.contains('Award')) {
                navProvider.setTab('portfolio');
              } else {
                // Fallback to roadmap or keep current
                navProvider.setTab('roadmap');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.getMainColor(context), AppColors.softGreen],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getMainColor(context).withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Text(
                'Continue',
                style: AppTextStyles.button.copyWith(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// people you know
class PeopleYouKnowWidget extends StatelessWidget {
  const PeopleYouKnowWidget({super.key});

  static final List<List<Color>> avatarGradients = [
    [Color(0xFFD4E09B), Color(0xFFCBDFBD)],
    [Color(0xFFCBDFBD), Color(0xFFA3B18A)],
    [Color(0xFFA3B18A), Color(0xFF588157)],
    [Color(0xFF588157), Color(0xFFD4E09B)],
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'People You Know',
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.getSurfaceColor(context),
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.getSurfaceColor(context)
                : Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.1),
          width: 1,
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
                colors: avatarGradients[index % avatarGradients.length],
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
                  builder: (context) => CareerProfileScreen(userId: user.uid),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.getMainColor(context),
                    AppColors.getSecondaryColor(context),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getMainColor(
                      context,
                    ).withValues(alpha: 0.2),
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
    );
  }
}
