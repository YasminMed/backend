import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:skillora/providers/goal_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

// UI Wrapper for Goal model
class GoalUI {
  final String id;
  final String title;
  final int progress;
  final bool isCompleted;

  GoalUI({
    required this.id,
    required this.title,
    required this.progress,
    this.isCompleted = false,
  });

  Color categoryColor(BuildContext context) => AppColors.getMainColor(context);
  IconData get categoryIcon => Icons.flag_outlined;
}

class StudentGoalScreen extends StatefulWidget {
  const StudentGoalScreen({super.key});

  @override
  State<StudentGoalScreen> createState() => _StudentGoalScreenState();
}

class _StudentGoalScreenState extends State<StudentGoalScreen> {
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalProvider>().fetchGoals();
    });
  }

  List<GoalUI> _getFilteredGoals(List<GoalUI> goals) {
    if (selectedFilter == 'All') return goals;
    if (selectedFilter == 'Active') {
      return goals.where((g) => !g.isCompleted && g.progress < 100).toList();
    }
    if (selectedFilter == 'Completed') {
      return goals.where((g) => g.isCompleted || g.progress == 100).toList();
    }
    return goals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        AppColors.getBackgroundColor(context),
                        AppColors.getBackgroundColor(context),
                        AppColors.getBackgroundColor(context),
                      ]
                    : [
                        AppColors.limeGreen.withValues(alpha: 0.15),
                        AppColors.getSurfaceColor(context),
                        AppColors.softGreen.withValues(alpha: 0.1),
                      ],
              ),
            ),
            child: SafeArea(
              child: Consumer<GoalProvider>(
                builder: (context, provider, child) {
                  final goals = provider.goals
                      .map(
                        (g) => GoalUI(
                          id: g.id,
                          title: g.title,
                          progress: g.progress,
                          isCompleted: g.isCompleted,
                        ),
                      )
                      .toList();

                  final filteredGoals = _getFilteredGoals(goals);
                  final activeGoals = goals.where((g) => !g.isCompleted).length;
                  final completedGoals = goals
                      .where((g) => g.isCompleted)
                      .length;
                  final totalProgress = goals.isEmpty
                      ? 0.0
                      : goals.fold<double>(0, (sum, g) => sum + g.progress) /
                            goals.length;

                  return Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: provider.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : RefreshIndicator(
                                onRefresh: () => provider.fetchGoals(),
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildGoalSummary(
                                        activeGoals,
                                        completedGoals,
                                        totalProgress,
                                      ),
                                      SizedBox(height: 20),
                                      _buildFilterChips(),
                                      SizedBox(height: 16),
                                      if (goals.isEmpty)
                                        _emptyState("No goals added yet!")
                                      else
                                        _buildGoalsList(filteredGoals),
                                      SizedBox(height: 80),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Floating button
          Positioned(
            bottom: 110,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.getMainColor(context), AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getMainColor(context).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _showAddGoalDialog,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: Icon(
                  Icons.add,
                  color: AppColors.getSurfaceColor(context),
                ),
                label: Text(
                  'Add Goal',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.getSurfaceColor(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    // Read the provider BEFORE the dialog opens
    final goalProvider = context.read<GoalProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(dialogContext),
        title: Text('Add Goal', style: AppTextStyles.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Goal Title'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                // Use pre-captured provider reference
                goalProvider.addGoal(titleController.text);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getMainColor(
                dialogContext,
                listen: false,
              ),
            ),
            child: Text(
              'Add',
              style: AppTextStyles.button.copyWith(
                color: AppColors.getSurfaceColor(dialogContext),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 64,
            color: AppColors.grey.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    ),
  );

  _buildAppBar() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.getMainColor(context), AppColors.accent],
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Center(
      child: Text(
        'My Goals',
        style: AppTextStyles.h2.copyWith(color: AppColors.white, fontSize: 20),
      ),
    ),
  );

  Widget _buildGoalSummary(int active, int completed, double progress) {
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
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goals Overview',
                style: AppTextStyles.h2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSummaryCard(
                    'Active',
                    '$active',
                    Icons.flag_outlined,
                    AppColors.getMainColor(context),
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    'Completed',
                    '$completed',
                    Icons.check_circle_outline,
                    AppColors.softGreen,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildProgressBar('Overall Progress', progress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.getSurfaceColor(context),
              AppColors.getSurfaceColor(context).withValues(alpha: 0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h1.copyWith(color: color, fontSize: 24),
            ),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: AppColors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.getSurfaceColor(context),
            AppColors.getSurfaceColor(context).withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.small.copyWith(color: AppColors.grey),
              ),
              Text(
                '${progress.toInt()}%',
                style: AppTextStyles.button.copyWith(
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.getSurfaceColor(context)
                      : AppColors.darkBrown),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (progress / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.getMainColor(context)],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Active', 'Completed'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppColors.getMainColor(context),
                            AppColors.accent,
                          ],
                        )
                      : null,
                  color: isSelected ? null : AppColors.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected
                        ? AppColors.getSurfaceColor(context)
                        : AppColors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalsList(List<GoalUI> filteredGoals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredGoals.map((goal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(goal.id),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              context.read<GoalProvider>().deleteGoal(goal.id);
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: _buildGoalCard(goal),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalCard(GoalUI goal) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: goal.categoryColor(context).withValues(alpha: 0.2),
              width: 1.5,
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
          Checkbox(
            value: goal.isCompleted,
            activeColor: goal.categoryColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (value) {
              context.read<GoalProvider>().toggleGoalStatus(
                    goal.id,
                    value ?? false,
                  );
            },
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              goal.title,
              style: AppTextStyles.button.copyWith(
                color: AppColors.getTextColor(context),
                decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showDeleteConfirmDialog(goal.id),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                size: 22,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    ),
    ),
    );
  }

  void _showDeleteConfirmDialog(String goalId) {
    final goalProvider = context.read<GoalProvider>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(dialogContext),
        title: Text('Delete Goal', style: AppTextStyles.h2),
        content: Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              goalProvider.deleteGoal(goalId);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              'Delete',
              style: AppTextStyles.button.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
