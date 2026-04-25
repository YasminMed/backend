import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillora/models/journey_model.dart';

class JourneyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<JourneyEvent> _journeyPoints = []; 
  bool _isLoading = false;

  List<JourneyEvent> get journeyPoints => _journeyPoints;
  bool get isLoading => _isLoading;

  String? get _userId => _auth.currentUser?.uid;// use auth to get logged user

  Future<void> fetchJourneyPoints() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('journey')
          .orderBy('timestamp', descending: true)
          .get();

      _journeyPoints = snapshot.docs
          .map((doc) => JourneyEvent.fromFirestore(doc.data(), doc.id))
          .toList();

      // Ensure sorting: Completed first (desc), then current, then upcoming
      _sortPoints();
    } catch (e) {
      debugPrint("Error fetching journey points: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _sortPoints() {
    _journeyPoints.sort((a, b) {
      // First by status (completed, current, upcoming)
      int statusCompare = a.status.index.compareTo(b.status.index);
      if (statusCompare != 0) return statusCompare;
      // Then by timestamp (newest first)
      return b.timestamp.compareTo(a.timestamp);
    });
  }

  //new timeline event
  Future<void> addJourneyPoint(
    String title,
    String description,
    JourneyEventType type,
    JourneyEventStatus status, {
    int? progress,
    String grade = '',
  }) async {
    if (_userId == null) return;

    try {
      final pointData = {
        'title': title,
        'description': description,
        'type': type.toString(),
        'status': status.toString(),
        'progress': progress,
        'grade': grade,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('journey')
          .add(pointData);

      _journeyPoints.add(
        JourneyEvent(
          id: docRef.id,
          title: title,
          description: description,
          type: type,
          status: status,
          progress: progress,
          grade: grade,
          timestamp: DateTime.now(),
        ),
      );

      _sortPoints();
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding journey point: $e");
    }
  }

  Future<void> deleteJourneyPoint(String pointId) async {
    if (_userId == null) return; 

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('journey')
          .doc(pointId)
          .delete(); //delete from firestore

      _journeyPoints.removeWhere((p) => p.id == pointId);// remove locally
      notifyListeners(); 
    } catch (e) {
      debugPrint("Error deleting journey point: $e");
    }
  }

  Future<void> updateJourneyPoint(
    String pointId,
    String title,
    String description,
    JourneyEventType type,
    JourneyEventStatus status, {
    int? progress,
    String grade = '',
  }) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('journey')
          .doc(pointId)
          .update({
            'title': title,
            'description': description,
            'type': type.toString(),
            'status': status.toString(),
            'progress': progress,
            'grade': grade,
          });

      //resort list
      int index = _journeyPoints.indexWhere((p) => p.id == pointId);
      if (index != -1) {
        _journeyPoints[index] = JourneyEvent(
          id: pointId,
          title: title,
          description: description,
          type: type,
          status: status,
          progress: progress,
          grade: grade,
          timestamp: _journeyPoints[index].timestamp,
        );
        _sortPoints();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating journey point: $e");
    }
  }
}
