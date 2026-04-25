import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillora/providers/journey_provider.dart';
import 'package:skillora/models/journey_model.dart' as model;
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JourneyProvider>().fetchJourneyPoints();
    });
  }

  List<model.JourneyEvent> _getFilteredEvents(List<model.JourneyEvent> events) {
    if (selectedFilter == 'All') return events;

    return events.where((e) {
      final name = e.status.name;
      final formatted = name[0].toUpperCase() + name.substring(1);
      return formatted == selectedFilter;
    }).toList();
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        AppColors.getBackgroundColor(context),
                        AppColors.getBackgroundColor(context),
                        AppColors.getBackgroundColor(context),
                      ]
                    : [
                        AppColors.limeGreen.withValues(alpha: 0.15),
                        AppColors.getBackgroundColor(context),
                        AppColors.softGreen.withValues(alpha: 0.1),
                      ],
              ),
            ),
            child: SafeArea(
              child: Consumer<JourneyProvider>(
                builder: (context, provider, child) {
                  final events = provider.journeyPoints;
                  final filteredEvents = _getFilteredEvents(events);

                  final counts = {
                    'Completed': events
                        .where(
                          (e) => e.status == model.JourneyEventStatus.completed,
                        )
                        .length,
                    'Current': events
                        .where(
                          (e) => e.status == model.JourneyEventStatus.current,
                        )
                        .length,
                    'Upcoming': events
                        .where(
                          (e) => e.status == model.JourneyEventStatus.upcoming,
                        )
                        .length,
                  };

                  return Column(
                    children: [
                      _buildAppBar(context),
                      Expanded(
                        child: provider.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : RefreshIndicator(
                                onRefresh: () => provider.fetchJourneyPoints(),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  physics: BouncingScrollPhysics(),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildJourneyStats(counts),
                                      SizedBox(height: 20),
                                      _buildFilterChips(),
                                      SizedBox(height: 20),
                                      Text(
                                        'Your Journey',
                                        style: AppTextStyles.h2.copyWith(
                                          fontSize: 22,
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      if (events.isEmpty)
                                        _emptyState(
                                          "Your journey is just beginning!",
                                        )
                                      else
                                        _buildTimeline(filteredEvents),
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
            bottom: 20,
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
                onPressed: _showAddMilestoneDialog,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: Icon(
                  Icons.add,
                  color: AppColors.getSurfaceColor(context),
                ),
                label: Text(
                  'Add Milestone',
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

  void _showAddMilestoneDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    model.JourneyEventType selectedType = model.JourneyEventType.milestone;
    model.JourneyEventStatus selectedStatus = model.JourneyEventStatus.upcoming;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.getSurfaceColor(context),
          title: Text('Add Journey Milestone', style: AppTextStyles.h2),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<model.JourneyEventType>(
                  value: selectedType,
                  items: model.JourneyEventType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.toString().split('.').last.toUpperCase(),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                  decoration: InputDecoration(labelText: 'Type'),
                ),
                DropdownButtonFormField<model.JourneyEventStatus>(
                  value: selectedStatus,
                  items: model.JourneyEventStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.toString().split('.').last.toUpperCase(),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedStatus = val);
                  },
                  decoration: InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(color: AppColors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  context.read<JourneyProvider>().addJourneyPoint(
                    titleController.text,
                    descController.text,
                    selectedType,
                    selectedStatus,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getMainColor(context, listen: false),
              ),
              child: Text(
                'Add',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.getSurfaceColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(
      child: Column(
        children: [
          Icon(
            Icons.map_outlined,
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

  Widget _buildAppBar(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.getMainColor(context), AppColors.accent],
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.getMainColor(context).withValues(alpha: 0.2),
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Center(
      child: Text(
        'My Journey',
        style: AppTextStyles.h2.copyWith(
          color: AppColors.getSurfaceColor(context),
          fontSize: 20,
        ),
      ),
    ),
  );

  Widget _buildJourneyStats(Map<String, int> counts) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: Theme.of(context).brightness == Brightness.dark
            ? [
                AppColors.getSurfaceColor(context),
                AppColors.getSurfaceColor(context),
              ]
            : [
                AppColors.getSurfaceColor(context),
                AppColors.limeGreen.withValues(alpha: 0.3),
              ],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 15,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: counts.entries.map((e) {
        return Column(
          children: [
            Icon(
              e.key == 'Completed'
                  ? Icons.check_circle
                  : e.key == 'Current'
                  ? Icons.play_circle_outline
                  : Icons.upcoming,
              color: AppColors.getMainColor(context),
            ),
            SizedBox(height: 6),
            Text('${e.value}', style: AppTextStyles.h1.copyWith(fontSize: 20)),
            Text(e.key, style: AppTextStyles.tiny.copyWith(fontSize: 11)),
          ],
        );
      }).toList(),
    ),
  );

  Widget _buildFilterChips() {
    final filters = ['All', 'Completed', 'Current', 'Upcoming'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final selected = f == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            AppColors.getMainColor(context),
                            AppColors.accent,
                          ],
                        )
                      : null,
                  color: selected ? null : AppColors.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.getMainColor(context)
                        : AppColors.grey.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  f,
                  style: AppTextStyles.label.copyWith(
                    color: selected
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

  Widget _buildTimeline(List<model.JourneyEvent> events) => Column(
    children: List.generate(events.length, (index) {
      final e = events[index];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      height: 20,
                      width: 2,
                      color: index == 0
                          ? Colors.transparent
                          : AppColors.getMainColor(context).withValues(alpha: 0.3),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: e.status == model.JourneyEventStatus.completed
                            ? AppColors.getMainColor(context)
                            : e.status == model.JourneyEventStatus.current
                            ? AppColors.accent
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.getMainColor(
                              context,
                            ).withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2,
                        color: index == events.length - 1
                            ? Colors.transparent
                            : AppColors.getMainColor(context).withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Dismissible(
                    key: Key(e.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => context
                        .read<JourneyProvider>()
                        .deleteJourneyPoint(e.id),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: _buildEventCard(e),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );

  Color _getTypeColor(model.JourneyEventType type) {
    switch (type) {
      case model.JourneyEventType.course:
        return AppColors.getMainColor(context);
      case model.JourneyEventType.achievement:
        return AppColors.accent;
      case model.JourneyEventType.project:
        return AppColors.limeGreen;
      case model.JourneyEventType.milestone:
        return AppColors.softGreen;
      case model.JourneyEventType.exam:
        return Colors.orange;
      case model.JourneyEventType.certification:
        return AppColors.accent;
    }
  }

  Widget _buildEventCard(model.JourneyEvent e) {
    final isCurrent = e.status == model.JourneyEventStatus.current;
    final typeColor = _getTypeColor(e.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.getSurfaceColor(context),
            typeColor.withValues(alpha: isCurrent ? 0.15 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: typeColor.withValues(alpha: isCurrent ? 0.4 : 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  e.typeName,
                  style: AppTextStyles.tiny.copyWith(
                    color: typeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              Spacer(),
              if (e.status == model.JourneyEventStatus.completed)
                Icon(
                  Icons.check_circle,
                  color: AppColors.getMainColor(context),
                  size: 16,
                ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                position: PopupMenuPosition.under,
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditJourneyDialog(e);
                  } else if (value == 'delete') {
                    _showDeleteJourneyConfirmDialog(e.id);
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.more_vert,
                    size: 22,
                    color: AppColors.getMainColor(context),
                  ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.getMainColor(context),
                        ),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            e.title,
            style: AppTextStyles.button.copyWith(
              fontSize: 16,
              color: AppColors.getTextColor(context),
            ),
          ),
          if (e.description.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              e.description,
              style: AppTextStyles.small.copyWith(
                fontSize: 13,
                color: AppColors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (isCurrent && e.progress != null) ...[
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (e.progress ?? 0) / 100,
                color: typeColor,
                backgroundColor: Colors.grey[200],
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditJourneyDialog(model.JourneyEvent e) {
    final titleController = TextEditingController(text: e.title);
    final descController = TextEditingController(text: e.description);
    model.JourneyEventType selectedType = e.type;
    model.JourneyEventStatus selectedStatus = e.status;
    final journeyProvider = context.read<JourneyProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AppColors.getSurfaceColor(dialogContext),
          title: Text('Edit Milestone', style: AppTextStyles.h2),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<model.JourneyEventType>(
                  value: selectedType,
                  items: model.JourneyEventType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                  decoration: InputDecoration(labelText: 'Type'),
                ),
                DropdownButtonFormField<model.JourneyEventStatus>(
                  value: selectedStatus,
                  items: model.JourneyEventStatus.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(s.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedStatus = val);
                  },
                  decoration: InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
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
                  journeyProvider.updateJourneyPoint(
                    e.id,
                    titleController.text,
                    descController.text,
                    selectedType,
                    selectedStatus,
                  );
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
                'Save',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.getSurfaceColor(dialogContext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteJourneyConfirmDialog(String pointId) {
    final journeyProvider = context.read<JourneyProvider>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(dialogContext),
        title: Text('Delete Milestone', style: AppTextStyles.h2),
        content: Text('Are you sure you want to delete this point?'),
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
              journeyProvider.deleteJourneyPoint(pointId);
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
