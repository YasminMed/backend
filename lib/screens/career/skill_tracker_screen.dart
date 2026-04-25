import 'package:flutter/material.dart';
import 'package:skillora/constants/app_colors.dart';

import 'package:provider/provider.dart';
import 'package:skillora/providers/portfolio_provider.dart';

import 'package:skillora/providers/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
      ],
      child: SkillTrackerApp(),
    ),
  );
}

class SkillTrackerApp extends StatelessWidget {
  const SkillTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors
            .green, // Using a generic green for the swatch as it is approximate
        scaffoldBackgroundColor: AppColors.getBackgroundColor(context),
        fontFamily: 'Inter',
      ),
      home: SkillTrackerScreen(),
    );
  }
}

class SkillTrackerScreen extends StatefulWidget {
  const SkillTrackerScreen({super.key});

  @override
  State<SkillTrackerScreen> createState() => _SkillTrackerScreenState();
}

class _SkillTrackerScreenState extends State<SkillTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFAFAFA), AppColors.getBackgroundColor(context)],
        ),
      ),
      child: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          final skills = portfolioProvider.skills;
          return SafeArea(
            child: Column(
              children: [
                const SkillTrackerAppBar(userName: 'Alex'),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkillsOverview(skills: skills),
                          const SizedBox(height: 24),
                          SkillsInProgress(skills: skills),
                          const SizedBox(height: 24),
                          const RecommendedSkills(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

//appbar
class SkillTrackerAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String userName;

  const SkillTrackerAppBar({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.getMainColor(context),
            AppColors.getSecondaryColor(context),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'Skill Tracker',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

// skillls overview
class SkillsOverview extends StatelessWidget {
  final List<PortfolioSkill> skills;

  const SkillsOverview({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.darkOlive,
            ),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Add skills in your Portfolio to see them here.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    final mappedSkills = skills.map((s) {
      return SkillOverviewData(
        name: s.name,
        progress: s.level / 100.0,
        color: Color(s.colorValue),
        icon: Icons.code, // default icon
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.darkOlive,
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: mappedSkills.length,
          itemBuilder: (context, index) {
            return CircularSkillCard(skill: mappedSkills[index]);
          },
        ),
      ],
    );
  }
}

class SkillOverviewData {
  final String name;
  final double progress;
  final Color color;
  final IconData icon;

  SkillOverviewData({
    required this.name,
    required this.progress,
    required this.color,
    required this.icon,
  });
}

class CircularSkillCard extends StatelessWidget {
  final SkillOverviewData skill;

  const CircularSkillCard({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white)
                        : Colors.black)
                    .withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 75,
            height: 75,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 75,
                  height: 75,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 6,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFF3F4F6),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                SizedBox(
                  width: 75,
                  height: 75,
                  child: CircularProgressIndicator(
                    value: skill.progress,
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(skill.color),
                    backgroundColor: Colors.transparent,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: skill.color.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(skill.icon, color: skill.color, size: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            skill.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkOlive,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 3),
          Text(
            '${(skill.progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: skill.color,
            ),
          ),
        ],
      ),
    );
  }
}

// skills in progress
class SkillsInProgress extends StatelessWidget {
  final List<PortfolioSkill> skills;

  const SkillsInProgress({super.key, required this.skills});

  String _getLevelText(int level) {
    if (level < 30) return 'Beginner';
    if (level < 70) return 'Intermediate';
    return 'Advanced';
  }

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) {
      return SizedBox.shrink(); // Hide section if no skills
    }

    final mappedSkills = skills.map((s) {
      return SkillProgressData(
        name: s.name,
        level: _getLevelText(s.level),
        completion: s.level / 100.0,
        color: Color(s.colorValue),
        xp: '${s.level * 5}/500 XP', // mock xp calculation based on level
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Skills in Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darkOlive,
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.darkOlive,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  'Keep going!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkOlive,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: mappedSkills.length,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            return SkillProgressCard(skill: mappedSkills[index]);
          },
        ),
      ],
    );
  }
}

class SkillProgressData {
  final String name;
  final String level;
  final double completion;
  final Color color;
  final String xp;

  SkillProgressData({
    required this.name,
    required this.level,
    required this.completion,
    required this.color,
    required this.xp,
  });
}

class SkillProgressCard extends StatelessWidget {
  final SkillProgressData skill;

  const SkillProgressCard({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white)
                        : Colors.black)
                    .withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: skill.color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: skill.color.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.book_outlined, color: skill.color, size: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkOlive,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            skill.level,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(skill.completion * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: skill.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: skill.completion,
                    backgroundColor: Color(0xFFF3F4F6),
                    valueColor: AlwaysStoppedAnimation<Color>(skill.color),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  skill.xp,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
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

// recommended skills
class RecommendedSkills extends StatelessWidget {
  const RecommendedSkills({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = [
      RecommendedSkillData(
        name: 'Machine Learning',
        category: 'AI & Data',
        duration: '12 weeks',
        icon: Icons.psychology_outlined,
        color: AppColors.getMainColor(context),
      ),
      RecommendedSkillData(
        name: 'Agile Management',
        category: 'Project Management',
        duration: '8 weeks',
        icon: Icons.track_changes_outlined,
        color: AppColors.getAccentColor(context),
      ),
      RecommendedSkillData(
        name: 'Creative Thinking',
        category: 'Soft Skills',
        duration: '6 weeks',
        icon: Icons.lightbulb_outline,
        color: AppColors.getSecondaryColor(context),
      ),
      RecommendedSkillData(
        name: 'TypeScript Mastery',
        category: 'Programming',
        duration: '10 weeks',
        icon: Icons.flash_on_outlined,
        color: AppColors.softGreen,
      ),
      RecommendedSkillData(
        name: 'Leadership Skills',
        category: 'Management',
        duration: '8 weeks',
        icon: Icons.groups_outlined,
        color: AppColors.lime,
      ),
      RecommendedSkillData(
        name: 'Growth Hacking',
        category: 'Marketing',
        duration: '7 weeks',
        icon: Icons.rocket_launch_outlined,
        color: AppColors.getMainColor(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recommended Skills to Learn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darkOlive,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: skills.length,
            separatorBuilder: (context, index) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              return RecommendedSkillCard(skill: skills[index]);
            },
          ),
        ),
      ],
    );
  }
}

class RecommendedSkillData {
  final String name;
  final String category;
  final String duration;
  final IconData icon;
  final Color color;

  RecommendedSkillData({
    required this.name,
    required this.category,
    required this.duration,
    required this.icon,
    required this.color,
  });
}

class RecommendedSkillCard extends StatelessWidget {
  final RecommendedSkillData skill;

  const RecommendedSkillCard({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white)
                        : Colors.black)
                    .withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: skill.color.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(skill.icon, color: skill.color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            skill.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkOlive,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            skill.category,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
          Spacer(),
          Text(
            skill.duration,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: skill.color,
            ),
          ),
        ],
      ),
    );
  }
}
