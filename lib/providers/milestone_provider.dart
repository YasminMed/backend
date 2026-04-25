import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Milestone {
  final String id;
  final String title;
  final bool isCompleted;

  Milestone({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory Milestone.fromFirestore(Map<String, dynamic> data, String id) {
    return Milestone(
      id: id,
      title: data['title'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

class MilestoneProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Milestone> _milestones = [];
  bool _isLoading = false;

  List<Milestone> get milestones => _milestones;
  bool get isLoading => _isLoading;

  String? get _userId => _auth.currentUser?.uid;

  int get completedCount => _milestones.where((m) => m.isCompleted).length;
  int get totalXP => completedCount * 500;

  String get rank {
    if (completedCount >= 10) return 'Expert';
    if (completedCount >= 5) return 'Mid';
    return 'Junior';
  }

  Future<void> fetchMilestones() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('career_milestones')
          .orderBy('createdAt')
          .get();

      _milestones = snapshot.docs
          .map((doc) => Milestone.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching milestones: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMilestone(String title) async {
    if (_userId == null) return;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('career_milestones')
          .add({
        'title': title,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _milestones.add(
        Milestone(
          id: docRef.id,
          title: title,
          isCompleted: false,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding milestone: $e");
    }
  }

  Future<void> toggleMilestoneStatus(String id, bool isCompleted) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('career_milestones')
          .doc(id)
          .update({
        'isCompleted': isCompleted,
      });

      int index = _milestones.indexWhere((m) => m.id == id);
      if (index != -1) {
        _milestones[index] = Milestone(
          id: id,
          title: _milestones[index].title,
          isCompleted: isCompleted,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error toggling milestone: $e");
    }
  }

  Future<void> deleteMilestone(String id) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('career_milestones')
          .doc(id)
          .delete();

      _milestones.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting milestone: $e");
    }
  }
}
