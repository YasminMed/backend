import 'package:cloud_firestore/cloud_firestore.dart';

enum JourneyEventType {
  course,
  achievement,
  project,
  milestone,
  exam,
  certification,
}

enum JourneyEventStatus { completed, current, upcoming }

class JourneyEvent {
  final String id;
  final String title;
  final String description;
  final String grade;
  final JourneyEventType type;
  final JourneyEventStatus status;
  final int? progress;
  final DateTime timestamp;

  JourneyEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    this.progress,
    this.grade = '',
    required this.timestamp,
  });

  factory JourneyEvent.fromFirestore(Map<String, dynamic> data, String id) {
    return JourneyEvent(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      grade: data['grade'] ?? '',
      type: JourneyEventType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => JourneyEventType.milestone,
      ),
      status: JourneyEventStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => JourneyEventStatus.upcoming,
      ),
      progress: data['progress'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'grade': grade,
      'type': type.toString(),
      'status': status.toString(),
      'progress': progress,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  String get typeName {
    final name = type.toString().split('.').last;
    return name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : name;
  }
}
