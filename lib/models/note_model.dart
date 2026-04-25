import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum NoteCategory { computerScience, mathematics, project }

class Note {
  final String id;
  final String title;
  final String content;
  final NoteCategory category;
  final bool isPinned;
  final DateTime timestamp;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.isPinned = false,
    required this.timestamp,
  });

  factory Note.fromFirestore(Map<String, dynamic> data, String id) {
    return Note(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: NoteCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => NoteCategory.computerScience,
      ),
      isPinned: data['isPinned'] ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'category': category.toString(),
      'isPinned': isPinned,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  String get categoryName {
    switch (category) {
      case NoteCategory.computerScience:
        return 'Computer Science';
      case NoteCategory.mathematics:
        return 'Mathematics';
      case NoteCategory.project:
        return 'Project';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case NoteCategory.computerScience:
        return Icons.computer;
      case NoteCategory.mathematics:
        return Icons.calculate;
      case NoteCategory.project:
        return Icons.folder;
    }
  }
}
