import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/constants/app_text_styles.dart';
import 'package:skillora/providers/portfolio_provider.dart';
import 'package:skillora/providers/activity_provider.dart';

//appbar
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key, this.title = "Portfolio"});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: preferredSize.height,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.getMainColor(context),
              AppColors.getSecondaryColor(context),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

// Models are now handled by PortfolioProvider

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String activeTab = 'projects';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().fetchData();
    });
  }

  void _showAddItemDialog() {
    final provider = context.read<PortfolioProvider>();
    final activityProvider = context.read<ActivityProvider>();

    if (activeTab == 'projects') {
      _showAddProjectDialog(provider, activityProvider);
    } else if (activeTab == 'skills') {
      _showAddSkillDialog(provider, activityProvider);
    } else {
      _showAddAwardDialog(provider, activityProvider);
    }
  }

  void _showAddProjectDialog(PortfolioProvider provider, ActivityProvider activityProvider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Add New Project', style: AppTextStyles.h2),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Project Title'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(labelText: 'Tags (comma separated)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final project = PortfolioProject(
                  id: '',
                  title: titleController.text,
                  description: descController.text,
                  colorValue: AppColors.getAccentColor(context, listen: false).toARGB32(),
                  tags: tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                  rating: 5,
                  link: '#',
                );
                provider.addProject(project);
                activityProvider.logActivity(
                  'Added Project: ${titleController.text}',
                  Icons.work_outline,
                );
                Navigator.pop(dialogContext);
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please enter a project title')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddSkillDialog(PortfolioProvider provider, ActivityProvider activityProvider) {
    final nameController = TextEditingController();
    double level = 50;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AppColors.getSurfaceColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Add New Skill', style: AppTextStyles.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Skill Name'),
              ),
              const SizedBox(height: 16),
              Text('Level: ${level.toInt()}%'),
              Slider(
                value: level,
                min: 0,
                max: 100,
                onChanged: (val) => setDialogState(() => level = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final skill = PortfolioSkill(
                    id: '',
                    name: nameController.text,
                    level: level.toInt(),
                    colorValue: AppColors.getMainColor(context, listen: false).toARGB32(),
                  );
                  provider.addSkill(skill);
                  activityProvider.logActivity(
                    'Added Skill: ${nameController.text}',
                    Icons.code,
                  );
                  Navigator.pop(dialogContext);
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please enter a skill name')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAwardDialog(PortfolioProvider provider, ActivityProvider activityProvider) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Add New Award', style: AppTextStyles.h2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Award Title'),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final award = PortfolioAward(
                  id: '',
                  title: titleController.text,
                  description: descController.text,
                  iconCode: Icons.emoji_events.codePoint,
                );
                provider.addAward(award);
                activityProvider.logActivity(
                  'Earned Award: ${titleController.text}',
                  Icons.emoji_events,
                );
                Navigator.pop(dialogContext);
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please enter an award title')),
                );
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.getBackgroundColor(context),
        child: Column(
          children: [
            AppBarWidget(title: "My Portfolio"),

            // content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    // Profile Card
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 24,
                        bottom: 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.softGreen,
                                        AppColors.getAccentColor(context),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'JD',
                                      style: AppTextStyles.body.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'John Doe',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.getTextColor(
                                            context,
                                          ),
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Full Stack Developer',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF9A9A9A),
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _buildSocialButton(Icons.code),
                                          SizedBox(width: 8),
                                          _buildSocialButton(
                                            Icons.business_center,
                                          ),
                                          SizedBox(width: 8),
                                          _buildSocialButton(Icons.email),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            // Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildStatItem(
                                      '${context.watch<PortfolioProvider>().projects.length}',
                                      'Projects',
                                      AppColors.getSecondaryColor(context),
                                    ),
                                    const SizedBox(width: 24),
                                    _buildStatItem(
                                      '${context.watch<PortfolioProvider>().skills.length}',
                                      'Skills',
                                      AppColors.getAccentColor(context),
                                    ),
                                    const SizedBox(width: 24),
                                    _buildStatItem(
                                      '${context.watch<PortfolioProvider>().awards.length}',
                                      'Awards',
                                      AppColors.lime,
                                    ),
                                  ],
                                ),
                                ClipOval(
                                  child: Material(
                                    color: AppColors.getMainColor(context),
                                    child: InkWell(
                                      onTap: _showAddItemDialog,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.getMainColor(context).withValues(alpha: 0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white, size: 24),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tab Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton('Projects', 'projects'),
                          ),
                          SizedBox(width: 8),
                          Expanded(child: _buildTabButton('Skills', 'skills')),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildTabButton('Awards', 'achievements'),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTabContent(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF5F5ED),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(icon, size: 16, color: Color(0xFF5A5A5A)),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFB0B0B0),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, String tab) {
    final isActive = activeTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          activeTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.getSecondaryColor(context)
              : AppColors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? AppColors.getSurfaceColor(context)
                  : AppColors.grey,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (activeTab) {
      case 'projects':
        return _buildProjectsTab();
      case 'skills':
        return _buildSkillsTab();
      case 'achievements':
        return _buildAchievementsTab();
      default:
        return _buildProjectsTab();
    }
  }

  Widget _buildProjectsTab() {
    final projects = context.watch<PortfolioProvider>().projects;
    if (projects.isEmpty) return _buildEmptyState('No projects yet. Tap "+" to add one!');

    return Column(
      children: projects.map((project) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(project.colorValue).withValues(alpha: 0.7), Color(project.colorValue)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.work_outline,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: AppTextStyles.h2,
                    ),
                    SizedBox(height: 8),
                    Text(
                      project.description,
                      style: AppTextStyles.secondary,
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: project.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.getSecondaryColor(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: AppTextStyles.tiny.copyWith(
                              color: AppColors.getSecondaryColor(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillsTab() {
    final skills = context.watch<PortfolioProvider>().skills;
    if (skills.isEmpty) return _buildEmptyState('No skills yet. Tap "+" to add one!');

    return Column(
      children: skills.map((skill) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    skill.name,
                    style: AppTextStyles.label,
                  ),
                  Text(
                    '${skill.level}%',
                    style: AppTextStyles.button.copyWith(color: Color(skill.colorValue)),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: skill.level / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(skill.colorValue),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementsTab() {
    final awards = context.watch<PortfolioProvider>().awards;
    if (awards.isEmpty) return _buildEmptyState('No awards yet. Tap "+" to add one!');

    return Column(
      children: awards.map((achievement) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.getAccentColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getIconData(achievement.iconCode),
                  size: 28,
                  color: AppColors.getAccentColor(context),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: AppTextStyles.label,
                    ),
                    SizedBox(height: 4),
                    Text(achievement.description, style: AppTextStyles.body),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.layers_clear_outlined, size: 48, color: AppColors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(message, style: AppTextStyles.secondary),
          ],
        ),
      ),
    );
  }
}

IconData _getIconData(int code) {
  if (code == Icons.emoji_events.codePoint) return Icons.emoji_events;
  if (code == Icons.work_outline.codePoint) return Icons.work_outline;
  if (code == Icons.code.codePoint) return Icons.code;
  if (code == Icons.stars.codePoint) return Icons.stars;
  return Icons.emoji_events;
}
