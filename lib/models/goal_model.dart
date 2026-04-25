class Goal {
  final String id;
  final String title;
  final int progress;
  final bool isCompleted;

  Goal({
    required this.id,
    required this.title,
    this.progress = 0,
    this.isCompleted = false,
  });

  factory Goal.fromFirestore(Map<String, dynamic> data, String id) {
    return Goal(
      id: id,
      title: data['title'] ?? '',
      progress: data['progress'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'title': title, 'progress': progress, 'isCompleted': isCompleted};
  }
}
