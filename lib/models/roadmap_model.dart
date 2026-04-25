
enum RoadmapStatus { locked, available, inProgress, completed }

class RoadmapItem {
  final String id;
  final String phase;
  final String title;
  final String duration;
  final RoadmapStatus status;
  final List<String> skills;
  final List<String> achievements;
  final int order;

  RoadmapItem({
    required this.id,
    required this.phase,
    required this.title,
    required this.duration,
    required this.status,
    required this.skills,
    required this.achievements,
    required this.order,
  });

  factory RoadmapItem.fromFirestore(Map<String, dynamic> data, String documentId) {
    return RoadmapItem(
      id: documentId,
      phase: data['phase'] ?? '',
      title: data['title'] ?? '',
      duration: data['duration'] ?? '',
      status: _statusFromString(data['status']),
      skills: List<String>.from(data['skills'] ?? []),
      achievements: List<String>.from(data['achievements'] ?? []),
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phase': phase,
      'title': title,
      'duration': duration,
      'status': _statusToString(status),
      'skills': skills,
      'achievements': achievements,
      'order': order,
    };
  }

  RoadmapItem copyWith({
    String? id,
    String? phase,
    String? title,
    String? duration,
    RoadmapStatus? status,
    List<String>? skills,
    List<String>? achievements,
    int? order,
  }) {
    return RoadmapItem(
      id: id ?? this.id,
      phase: phase ?? this.phase,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      skills: skills ?? this.skills,
      achievements: achievements ?? this.achievements,
      order: order ?? this.order,
    );
  }

  static RoadmapStatus _statusFromString(String? status) {
    switch (status) {
      case 'locked':
        return RoadmapStatus.locked;
      case 'available':
        return RoadmapStatus.available;
      case 'inProgress':
        return RoadmapStatus.inProgress;
      case 'completed':
        return RoadmapStatus.completed;
      default:
        return RoadmapStatus.locked;
    }
  }

  static String _statusToString(RoadmapStatus status) {
    switch (status) {
      case RoadmapStatus.locked:
        return 'locked';
      case RoadmapStatus.available:
        return 'available';
      case RoadmapStatus.inProgress:
        return 'inProgress';
      case RoadmapStatus.completed:
        return 'completed';
    }
  }
}
