import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillora/models/note_model.dart';

class NoteProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  String? get _userId => _auth.currentUser?.uid; 

  Future<void> fetchNotes() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notes')
          .orderBy('timestamp', descending: true)//newest notes appears first
          .get();

      _notes = snapshot.docs
          .map((doc) => Note.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Error fetching notes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(
    String title,
    String content,
    NoteCategory category,
  ) async {
    final uid = _userId;
    debugPrint("📝 addNote called — uid: $uid, title: $title");

    if (uid == null) {
      debugPrint("❌ addNote aborted: user is not logged in (uid is null)");
      return;
    }

    try {
      debugPrint("📤 Writing note to Firestore path: users/$uid/notes");
      final noteData = {
        'title': title,
        'content': content,
        'category': category.toString(),
        'isPinned': false,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .add(noteData);

      debugPrint("✅ Note saved successfully with id: ${docRef.id}");

        //save to firestore, get doc ID, intsert locally at top
      _notes.insert(
        0,
        Note(
          id: docRef.id,
          title: title,
          content: content,
          category: category,
          timestamp: DateTime.now(),
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error adding note: $e");
    }
  }

  Future<void> deleteNote(String noteId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notes')
          .doc(noteId)
          .delete();

      _notes.removeWhere((n) => n.id == noteId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error deleting note: $e");
    }
  }

  Future<void> updateNote(
    String noteId,
    String title,
    String content,
    NoteCategory category,
  ) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notes')
          .doc(noteId)
          .update({
            'title': title,
            'content': content,
            'category': category.toString(),
          });

      int index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        _notes[index] = Note(
          id: noteId,
          title: title,
          content: content,
          category: category,
          isPinned: _notes[index].isPinned,
          timestamp: _notes[index].timestamp,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating note: $e");
    }
  }

  Future<void> togglePin(String noteId) async {
    if (_userId == null) return;

    final noteIndex = _notes.indexWhere((n) => n.id == noteId);
    if (noteIndex == -1) return;

    final newPinnedStatus = !_notes[noteIndex].isPinned;

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notes')
          .doc(noteId)
          .update({'isPinned': newPinnedStatus});

      _notes[noteIndex] = Note(
        id: _notes[noteIndex].id,
        title: _notes[noteIndex].title,
        content: _notes[noteIndex].content,
        category: _notes[noteIndex].category,
        isPinned: newPinnedStatus,
        timestamp: _notes[noteIndex].timestamp,
      );

      // Re-sort notes
      _notes.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.timestamp.compareTo(a.timestamp);
      });

      notifyListeners();
    } catch (e) {
      debugPrint("Error toggling pin: $e");
    }
  }
}
