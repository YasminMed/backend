import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillora/models/roadmap_model.dart';

class RoadmapProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<RoadmapItem> _roadmapItems = [];
  bool _isLoading = false;

  List<RoadmapItem> get roadmapItems => _roadmapItems;
  bool get isLoading => _isLoading;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> fetchRoadmap() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('roadmaps')
          .orderBy('order')
          .get();

      if (snapshot.docs.isEmpty) {
        // Auto-generate a default template if the user has no roadmap
        await generateRoadmap("Software Development", "0-2 Years");
        return;
      }

      _roadmapItems = snapshot.docs
          .map((doc) => RoadmapItem.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching roadmap: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generateRoadmap(String field, String experience) async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Delete existing roadmap phases
      final currentRoadmap = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('roadmaps')
          .get();
      
      for (var doc in currentRoadmap.docs) {
        await doc.reference.delete();
      }

      // Generate template based on selected field and experience
      final List<Map<String, dynamic>> templates = [
        {
          'phase': 'Phase 1',
          'title': 'Junior $field',
          'duration': '0-2 Years',
          'status': 'available', // The first phase is always available to start
          'skills': ['Fundamentals', 'Basic Tools', 'Core Concepts'],
          'achievements': ['Complete basic projects', 'Learn core concepts'],
          'order': 1,
        },
        {
          'phase': 'Phase 2',
          'title': 'Mid-Level $field',
          'duration': '2-4 Years',
          'status': 'locked',
          'skills': ['Advanced Concepts', 'System Design', 'Performance'],
          'achievements': ['Lead smaller projects', 'Mentor juniors'],
          'order': 2,
        },
        {
          'phase': 'Phase 3',
          'title': 'Senior $field',
          'duration': '4-6 Years',
          'status': 'locked',
          'skills': ['Leadership', 'Complex Problem Solving', 'Architecture'],
          'achievements': ['Architect solutions', 'Tech leadership'],
          'order': 3,
        },
        {
          'phase': 'Phase 4',
          'title': 'Lead / Manager in $field',
          'duration': '6+ Years',
          'status': 'locked',
          'skills': ['Team Management', 'Project Planning', 'Cross-functional'],
          'achievements': ['Drive technical decisions', 'Shape tech direction'],
          'order': 4,
        },
      ];

      for (var item in templates) {
        await _firestore
            .collection('users')
            .doc(_userId)
            .collection('roadmaps')
            .add(item);
      }

      // Fetch the newly generated roadmap to update state
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('roadmaps')
          .orderBy('order')
          .get();
      
      _roadmapItems = snapshot.docs
          .map((doc) => RoadmapItem.fromFirestore(doc.data(), doc.id))
          .toList();
          
    } catch (e) {
      debugPrint("Error generating roadmap: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startPhase(String phaseId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('roadmaps')
          .doc(phaseId)
          .update({'status': 'inProgress'});

      int index = _roadmapItems.indexWhere((k) => k.id == phaseId);
      if (index != -1) {
        _roadmapItems[index] = _roadmapItems[index].copyWith(status: RoadmapStatus.inProgress);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error starting phase: $e");
    }
  }

  Future<void> completePhase(String phaseId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('roadmaps')
          .doc(phaseId)
          .update({'status': 'completed'});

      int index = _roadmapItems.indexWhere((k) => k.id == phaseId);
      if (index != -1) {
        _roadmapItems[index] = _roadmapItems[index].copyWith(status: RoadmapStatus.completed);
        
        // Find next phase and unlock it (set to available)
        int nextIndex = index + 1;
        if (nextIndex < _roadmapItems.length) {
          final nextPhase = _roadmapItems[nextIndex];
          await _firestore
              .collection('users')
              .doc(_userId)
              .collection('roadmaps')
              .doc(nextPhase.id)
              .update({'status': 'available'});
          _roadmapItems[nextIndex] = nextPhase.copyWith(status: RoadmapStatus.available);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error completing phase: $e");
    }
  }
}
