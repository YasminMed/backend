import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillora/models/goal_model.dart';

class GoalProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  String? get _userId => _auth.currentUser?.uid;
  
  //counts completed goals
  int get completedGoalsCount => _goals.where((g) => g.isCompleted).length;
  
  int get totalExperiencePoints => completedGoalsCount * 500; //each goal = 500xp
  
  String get rank {
    if (completedGoalsCount >= 10) return 'Expert';
    if (completedGoalsCount >= 5) return 'Mid';
    return 'Junior';
  }

  Future<void> fetchGoals() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('goals')
          .get(); //read firestore

      _goals = snapshot.docs
          .map((doc) => Goal.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching goals: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(String title) async {
    if (_userId == null) return;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('goals')
          .add({
            'title': title,
            'progress': 0,
            'isCompleted': false,
          });

      _goals.add(
        Goal(
          id: docRef.id,
          title: title,
          progress: 0,
          isCompleted: false,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding goal: $e");
    }
  }

  Future<void> updateGoal(String goalId, String title) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('goals')
          .doc(goalId)
          .update({
            'title': title,
          });

      int index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = Goal(
          id: goalId,
          title: title,
          progress: _goals[index].progress,
          isCompleted: _goals[index].isCompleted,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating goal: $e");
    }
  }

  Future<void> toggleGoalStatus(String goalId, bool isCompleted) async {
    if (_userId == null) return;

    try {
      final progress = isCompleted ? 100 : 0;
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('goals')
          .doc(goalId)
          .update({
            'isCompleted': isCompleted,
            'progress': progress,
          });

      int index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = Goal(
          id: goalId,
          title: _goals[index].title,
          progress: progress,
          isCompleted: isCompleted,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error toggling goal status: $e");
    }
  }

  Future<void> deleteGoal(String goalId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('goals')
          .doc(goalId)
          .delete();

      _goals.removeWhere((g) => g.id == goalId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting goal: $e");
    }
  }
}
