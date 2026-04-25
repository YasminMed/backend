import 'package:flutter/material.dart';

class Course {
  final String id;
  final String title;
  final String difficulty;
  final String duration;
  final String iconName; 
  final int progress;
  final double hours;
  final bool isRegistered;
  final int totalWeeks;
  final List<bool> completedWeeks;
  final List<String> weekContents;

  Course({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.duration,
    required this.iconName,
    this.progress = 0,
    this.hours = 0.0,
    this.isRegistered = false,
    this.totalWeeks = 1,
    List<bool>? completedWeeks,
    List<String>? weekContents,
  })  : completedWeeks = completedWeeks ?? List.filled(totalWeeks, false),
        weekContents = weekContents ?? List.filled(totalWeeks, "");

  factory Course.fromFirestore(Map<String, dynamic> data, String id) {
    final int tw = data['totalWeeks'] ?? 1;
    return Course(
      id: id,
      title: data['title'] ?? '',
      difficulty: data['difficulty'] ?? 'Easy',
      duration: data['duration'] ?? '',
      iconName: data['iconName'] ?? 'code',
      progress: data['progress'] ?? 0,
      hours: (data['hours'] ?? 0).toDouble(),
      isRegistered: data['isRegistered'] ?? false,
      totalWeeks: tw,
      completedWeeks: data['completedWeeks'] != null
          ? List<bool>.from(data['completedWeeks'])
          : List.filled(tw, false),
      weekContents: data['weekContents'] != null
          ? List<String>.from(data['weekContents'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'difficulty': difficulty,
      'duration': duration,
      'iconName': iconName,
      'progress': progress,
      'hours': hours,
      'isRegistered': isRegistered,
      'totalWeeks': totalWeeks,
      'completedWeeks': completedWeeks,
      'weekContents': weekContents,
    };
  }

  // Icon mapping
  IconData get icon {
    switch (iconName) {
      case 'code':
        return Icons.code;
      case 'palette':
        return Icons.palette;
      case 'psychology':
        return Icons.psychology;
      case 'memory':
        return Icons.memory;
      case 'security':
        return Icons.security;
      case 'brush':
        return Icons.brush;
      default:
        return Icons.book;
    }
  }
}
