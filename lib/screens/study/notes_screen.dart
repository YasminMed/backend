import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillora/providers/note_provider.dart';
import 'package:skillora/models/note_model.dart' as model;
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class NotesWidget extends StatefulWidget {
  const NotesWidget({super.key});

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  String selectedCategory = 'All';
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().fetchNotes();
    });
  }

  List<model.Note> _getFilteredNotes(List<model.Note> notes) {
    List<model.Note> filtered = notes;

    if (selectedCategory != 'All') {
      filtered = filtered
          .where((note) => note.categoryName == selectedCategory)
          .toList();
    }

    // Sorting is already handled in provider for pinned notes and timestamp
    return filtered;
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
                        AppColors.getSurfaceColor(context),
                        AppColors.softGreen.withValues(alpha: 0.10),
                      ],
              ),
            ),
            child: SafeArea(
              child: Consumer<NoteProvider>(
                builder: (context, provider, child) {
                  final filteredNotes = _getFilteredNotes(provider.notes);
                  final totalNotes = provider.notes.length;
                  final pinnedNotes = provider.notes
                      .where((n) => n.isPinned)
                      .length;

                  return Column(
                    children: [
                      _buildAppBar(context),
                      SizedBox(height: 24),
                      _buildStatsCards(totalNotes, pinnedNotes, totalNotes),
                      _buildFilterChips(),
                      Expanded(
                        child: provider.isLoading
                            ? Center(child: CircularProgressIndicator())
                            : RefreshIndicator(
                                onRefresh: () => provider.fetchNotes(),
                                child: _buildNotesContent(filteredNotes),
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
                onPressed: _showAddNoteDialog,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: Icon(
                  Icons.add,
                  color: AppColors.getSurfaceColor(context),
                ),
                label: Text(
                  'Add Note',
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

  Widget _buildNotesContent(List<model.Note> filteredNotes) {
    if (filteredNotes.isEmpty) {
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: _emptyState("No notes added yet!"),
        ),
      );
    }

    return isGridView
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (int i = 0; i < filteredNotes.length; i += 2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildNoteCardGrid(filteredNotes[i]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      for (int i = 1; i < filteredNotes.length; i += 2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildNoteCardGrid(filteredNotes[i]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: filteredNotes.length,
            itemBuilder: (context, index) =>
                _buildNoteCardList(filteredNotes[index]),
          );
  }

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    model.NoteCategory selectedCat = model.NoteCategory.computerScience;
    // Read the provider BEFORE the dialog opens — most reliable approach
    final noteProvider = context.read<NoteProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.getSurfaceColor(dialogContext),
              title: Text('Add Note', style: AppTextStyles.h2),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(labelText: 'Content'),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<model.NoteCategory>(
                    value: selectedCat,
                    items: model.NoteCategory.values.map((cat) {
                      String name = '';
                      switch (cat) {
                        case model.NoteCategory.computerScience:
                          name = 'Computer Science';
                          break;
                        case model.NoteCategory.mathematics:
                          name = 'Mathematics';
                          break;
                        case model.NoteCategory.project:
                          name = 'Project';
                          break;
                      }
                      return DropdownMenuItem(value: cat, child: Text(name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCat = val);
                    },
                    decoration: InputDecoration(labelText: 'Category'),
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
                    if (titleController.text.isNotEmpty &&
                        contentController.text.isNotEmpty) {
                      // Use pre-captured provider reference
                      noteProvider.addNote(
                        titleController.text,
                        contentController.text,
                        selectedCat,
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getMainColor(
                      context,
                      listen: false,
                    ),
                  ),
                  child: Text(
                    'Add',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.getSurfaceColor(context),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _emptyState(String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notes, size: 64, color: AppColors.grey.withValues(alpha: 0.3)),
        SizedBox(height: 16),
        Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.grey),
        ),
      ],
    ),
  );

  Widget _buildAppBar(BuildContext context) {
    return Container(
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'My Notes',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontSize: 20,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => setState(() => isGridView = !isGridView),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceColor(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isGridView ? Icons.view_list : Icons.grid_view,
                  color: AppColors.getSurfaceColor(context),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(int total, int pinned, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  AppColors.getSurfaceColor(context),
                  AppColors.getSurfaceColor(context),
                ]
              : [
                  AppColors.getSurfaceColor(context),
                  AppColors.limeGreen.withValues(alpha: 0.2),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.limeGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              '$total',
              Icons.note_outlined,
              AppColors.getMainColor(context),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.grey.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Pinned',
              '$pinned',
              Icons.push_pin,
              AppColors.accent,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.grey.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'Recent',
              '$count',
              Icons.history,
              AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(color: color, fontSize: 20),
        ),
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(
            color: AppColors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final categories = ['All', 'Computer Science', 'Mathematics', 'Project'];

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
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
                  border: Border.all(
                    color: isSelected
                        ? AppColors.getMainColor(context)
                        : AppColors.grey.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.getMainColor(context).withValues(alpha: 0.3)
                          : AppColors.getSurfaceColor(
                              context,
                            ).withValues(alpha: 0.05),
                      blurRadius: isSelected ? 8 : 5,
                    ),
                  ],
                ),
                child: Text(
                  category,
                  style: AppTextStyles.label.copyWith(
                    color: isSelected
                        ? AppColors.getSurfaceColor(context)
                        : AppColors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteCardList(model.Note note) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        context.read<NoteProvider>().deleteNote(note.id);
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    AppColors.getSurfaceColor(context),
                    AppColors.getSurfaceColor(context),
                  ]
                : [
                    AppColors.getSurfaceColor(context),
                    AppColors.getMainColor(context).withValues(alpha: 0.08),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.getMainColor(context).withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.getMainColor(context).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    note.categoryIcon,
                    color: AppColors.getMainColor(context),
                    size: 18,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (note.isPinned) ...[
                            Icon(
                              Icons.push_pin,
                              size: 14,
                              color: AppColors.getMainColor(context),
                            ),
                            SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              note.title,
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.getTextColor(
                                  context,
                                ).withValues(alpha: 0.87),
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        note.categoryName,
                        style: AppTextStyles.tiny.copyWith(
                          color: AppColors.getMainColor(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => context.read<NoteProvider>().togglePin(note.id),
                  child: Icon(
                    note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: note.isPinned ? AppColors.accent : AppColors.grey,
                    size: 20,
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteNoteConfirmDialog(note.id),
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
            SizedBox(height: 12),
            Text(
              note.content,
              style: AppTextStyles.small.copyWith(
                color: AppColors.grey,
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCardGrid(model.Note note) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.vertical,
      onDismissed: (direction) {
        context.read<NoteProvider>().deleteNote(note.id);
      },
      background: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    AppColors.getSurfaceColor(context),
                    AppColors.getSurfaceColor(context),
                  ]
                : [
                    AppColors.getSurfaceColor(context),
                    AppColors.getMainColor(context).withValues(alpha: 0.12),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.getMainColor(context).withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.getSurfaceColor(context).withValues(alpha: 0.08),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.getMainColor(context).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    note.categoryIcon,
                    color: AppColors.getMainColor(context),
                    size: 20,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          context.read<NoteProvider>().togglePin(note.id),
                      child: Icon(
                        note.isPinned
                            ? Icons.push_pin
                            : Icons.push_pin_outlined,
                        size: 16,
                        color: note.isPinned
                            ? AppColors.accent
                            : AppColors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showDeleteNoteConfirmDialog(note.id),
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              note.title,
              style: AppTextStyles.button.copyWith(
                color: AppColors.getTextColor(context).withValues(alpha: 0.87),
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6),
            Text(
              note.content,
              style: AppTextStyles.small.copyWith(
                color: AppColors.grey,
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteNoteConfirmDialog(String noteId) {
    final noteProvider = context.read<NoteProvider>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getSurfaceColor(dialogContext),
        title: Text('Delete Note', style: AppTextStyles.h2),
        content: Text('Are you sure you want to delete this note?'),
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
              noteProvider.deleteNote(noteId);
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
