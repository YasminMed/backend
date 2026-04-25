import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CareerActivity {
  final String id;
  final String title;
  final int progress;
  final IconData icon;
  final DateTime timestamp;

  CareerActivity({
    required this.id,
    required this.title,
    required this.progress,
    required this.icon,
    required this.timestamp,
  });

  factory CareerActivity.fromFirestore(Map<String, dynamic> data, String id) {
    return CareerActivity(
      id: id,
      title: data['title'] ?? '',
      progress: data['progress'] ?? 0,
      icon: _getIconData(data['iconCode']),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'progress': progress,
      'iconCode': icon.codePoint,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class ActivityProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<CareerActivity> _activities = [];
  bool _isLoading = false;

  List<CareerActivity> get activities => _activities;
  bool get isLoading => _isLoading;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> fetchActivities() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('career_activities')
          .orderBy('timestamp', descending: true)
          .get();

      _activities = snapshot.docs
          .map((doc) => CareerActivity.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching activities: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logActivity(String title, IconData icon, {int progress = 100}) async {
    if (_userId == null) return;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('career_activities')
          .add({
        'title': title,
        'progress': progress,
        'iconCode': icon.codePoint,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _activities.insert(
        0,
        CareerActivity(
          id: docRef.id,
          title: title,
          progress: progress,
          icon: icon,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error logging activity: $e");
    }
  }
}

IconData _getIconData(dynamic code) {
  if (code == Icons.emoji_events.codePoint) return Icons.emoji_events;
  if (code == Icons.work_outline.codePoint) return Icons.work_outline;
  if (code == Icons.code.codePoint) return Icons.code;
  if (code == Icons.stars.codePoint) return Icons.stars;
  return Icons.stars;
}
