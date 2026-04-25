import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/constants/app_text_styles.dart';
import 'package:skillora/models/roadmap_model.dart';
import 'package:skillora/providers/roadmap_provider.dart';

//appbar
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key, this.title = "Career Roadmap"});
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
              color: AppColors.getSurfaceColor(context) == Colors.white
                  ? AppColors.darkOlive
                  : AppColors.getTextColor(context),
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

//roadmap screen
class CareerRoadmapScreenWidget extends StatefulWidget {
  const CareerRoadmapScreenWidget({super.key});

  @override
  State<CareerRoadmapScreenWidget> createState() => _CareerRoadmapScreenWidgetState();
}

class _CareerRoadmapScreenWidgetState extends State<CareerRoadmapScreenWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<RoadmapProvider>().fetchRoadmap();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoadmapProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Column(
            children: [
              const AppBarWidget(),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        }

        return Column(
          children: [
            const AppBarWidget(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(context),
                    const SizedBox(height: 24),
                    Text(
                      "Your Journey",
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.getTextColor(context) == Colors.white
                            ? Colors.white
                            : AppColors.darkOlive,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...provider.roadmapItems.map((item) {
                      return _buildRoadmapItem(
                        context,
                        item: item,
                        provider: provider,
                      );
                    }),
                    if (provider.roadmapItems.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text("No roadmap generated yet. Customize to get started!"),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _buildActionButton(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final cardColor = AppColors.getSurfaceColor(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4E09B), Color(0xFFCBDFBD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.map_outlined, color: cardColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Career Path",
                      style: AppTextStyles.h2.copyWith(
                        color: cardColor,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Track your progress and plan ahead",
                      style: AppTextStyles.small.copyWith(
                        color: cardColor.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapItem(
    BuildContext context, {
    required RoadmapItem item,
    required RoadmapProvider provider,
  }) {
    Color statusColor = _getStatusColor(context, item.status);
    IconData statusIcon = _getStatusIcon(item.status);
    String statusText = _getStatusText(item.status);
    final cardColor = AppColors.getSurfaceColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: cardColor, width: 3),
                ),
                child: Icon(statusIcon, color: cardColor, size: 24),
              ),
              if (item.status != RoadmapStatus.locked)
                Container(
                  width: 3,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [statusColor, statusColor.withValues(alpha: 0.3)],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cardColor, statusColor.withValues(alpha: 0.1)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.phase,
                    style: AppTextStyles.tiny.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 18,
                      color: AppColors.getTextColor(context) == Colors.white
                          ? Colors.white
                          : AppColors.darkOlive,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.duration,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: AppTextStyles.tiny.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Display Interactive Actions
                  if (item.status == RoadmapStatus.available) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => provider.startPhase(item.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.getMainColor(context),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Start Phase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ] else if (item.status == RoadmapStatus.inProgress) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => provider.completePhase(item.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.getSecondaryColor(context),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Finish Phase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4E09B), Color(0xFFCBDFBD)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const CustomizeRoadmapSheet(),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          "Customize Your Roadmap",
          style: AppTextStyles.button.copyWith(
            color: AppColors.getTextColor(context) == Colors.white
                ? Colors.white
                : AppColors.darkOlive,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, RoadmapStatus status) {
    switch (status) {
      case RoadmapStatus.completed:
        return AppColors.getMainColor(context);
      case RoadmapStatus.inProgress:
        return AppColors.getAccentColor(context);
      case RoadmapStatus.available:
        return AppColors.lime;
      case RoadmapStatus.locked:
        return Colors.grey.shade400;
    }
  }

  IconData _getStatusIcon(RoadmapStatus status) {
    switch (status) {
      case RoadmapStatus.completed:
        return Icons.check_circle;
      case RoadmapStatus.inProgress:
        return Icons.play_circle_filled;
      case RoadmapStatus.available:
        return Icons.schedule;
      case RoadmapStatus.locked:
        return Icons.lock_outline;
    }
  }

  String _getStatusText(RoadmapStatus status) {
    switch (status) {
      case RoadmapStatus.completed:
        return "Completed";
      case RoadmapStatus.inProgress:
        return "In Progress";
      case RoadmapStatus.available:
        return "Available";
      case RoadmapStatus.locked:
        return "Locked";
    }
  }
}

class CustomizeRoadmapSheet extends StatefulWidget {
  const CustomizeRoadmapSheet({super.key});

  @override
  State<CustomizeRoadmapSheet> createState() => _CustomizeRoadmapSheetState();
}

class _CustomizeRoadmapSheetState extends State<CustomizeRoadmapSheet> {
  final TextEditingController _careerGoalController = TextEditingController();
  String _selectedExperience = "0-2 Years";
  String _selectedField = "Software Development";

  final List<String> _experienceLevels = [
    "0-2 Years",
    "2-4 Years",
    "4-6 Years",
    "6-8 Years",
    "8+ Years",
  ];
  final List<String> _careerFields = [
    "Software Development",
    "Data Science",
    "Product Management",
    "UI/UX Design",
    "DevOps Engineering",
    "Mobile Development",
  ];

  @override
  void dispose() {
    _careerGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.getTextColor(context),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Customize Roadmap",
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 20,
                    color: AppColors.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Career Goal",
                    style: AppTextStyles.label.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _careerGoalController,
                    decoration: InputDecoration(
                      hintText: "e.g., Senior Software Engineer",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Experience Level",
                    style: AppTextStyles.label.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedExperience,
                    items: _experienceLevels
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedExperience = value!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Field",
                    style: AppTextStyles.label.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedField,
                    items: _careerFields
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedField = value!),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4E09B), Color(0xFFCBDFBD)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<RoadmapProvider>().generateRoadmap(
                          _selectedField,
                          _selectedExperience,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Save Changes",
                        style: AppTextStyles.button.copyWith(
                          color:
                              AppColors.getSurfaceColor(context) == Colors.white
                              ? AppColors.darkOlive
                              : AppColors.getTextColor(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
