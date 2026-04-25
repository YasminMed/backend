import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PortfolioProject {
  final String id;
  final String title;
  final String description;
  final int colorValue;
  final List<String> tags;
  final int rating;
  final String link;

  PortfolioProject({
    required this.id,
    required this.title,
    required this.description,
    required this.colorValue,
    required this.tags,
    required this.rating,
    required this.link,
  });

  factory PortfolioProject.fromFirestore(Map<String, dynamic> data, String id) {
    return PortfolioProject(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      colorValue: data['colorValue'] ?? 0xFFD4E09B,
      tags: List<String>.from(data['tags'] ?? []),
      rating: data['rating'] ?? 5,
      link: data['link'] ?? '#',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'colorValue': colorValue,
      'tags': tags,
      'rating': rating,
      'link': link,
    };
  }
}

class PortfolioSkill {
  final String id;
  final String name;
  final int level;
  final int colorValue;

  PortfolioSkill({
    required this.id,
    required this.name,
    required this.level,
    required this.colorValue,
  });

  factory PortfolioSkill.fromFirestore(Map<String, dynamic> data, String id) {
    return PortfolioSkill(
      id: id,
      name: data['name'] ?? '',
      level: data['level'] ?? 0,
      colorValue: data['colorValue'] ?? 0xFFD4E09B,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'level': level,
      'colorValue': colorValue,
    };
  }
}

class PortfolioAward {
  final String id;
  final String title;
  final String description;
  final int iconCode;

  PortfolioAward({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCode,
  });

  factory PortfolioAward.fromFirestore(Map<String, dynamic> data, String id) {
    return PortfolioAward(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      iconCode: data['iconCode'] ?? Icons.emoji_events.codePoint,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'iconCode': iconCode,
    };
  }
}

class PortfolioProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<PortfolioProject> _projects = [];
  List<PortfolioSkill> _skills = [];
  List<PortfolioAward> _awards = [];
  bool _isLoading = false;

  List<PortfolioProject> get projects => _projects;
  List<PortfolioSkill> get skills => _skills;
  List<PortfolioAward> get awards => _awards;
  bool get isLoading => _isLoading;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> fetchData() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final portfolioRef = _firestore.collection('users').doc(_userId).collection('portfolio');
      
      final projectsSnap = await portfolioRef.doc('data').collection('projects').get();
      final skillsSnap = await portfolioRef.doc('data').collection('skills').get();
      final awardsSnap = await portfolioRef.doc('data').collection('awards').get();

      _projects = projectsSnap.docs.map((doc) => PortfolioProject.fromFirestore(doc.data(), doc.id)).toList();
      _skills = skillsSnap.docs.map((doc) => PortfolioSkill.fromFirestore(doc.data(), doc.id)).toList();
      _awards = awardsSnap.docs.map((doc) => PortfolioAward.fromFirestore(doc.data(), doc.id)).toList();

    } catch (e) {
      debugPrint("Error fetching portfolio data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProject(PortfolioProject project) async {
    if (_userId == null) {
      _projects.add(PortfolioProject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: project.title,
        description: project.description,
        colorValue: project.colorValue,
        tags: project.tags,
        rating: project.rating,
        link: project.link,
      ));
      notifyListeners();
      return;
    }
    try {
      final docRef = await _firestore.collection('users').doc(_userId).collection('portfolio').doc('data').collection('projects').add(project.toFirestore());
      _projects.add(PortfolioProject(
        id: docRef.id,
        title: project.title,
        description: project.description,
        colorValue: project.colorValue,
        tags: project.tags,
        rating: project.rating,
        link: project.link,
      ));
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding project: $e");
      _projects.add(PortfolioProject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: project.title,
        description: project.description,
        colorValue: project.colorValue,
        tags: project.tags,
        rating: project.rating,
        link: project.link,
      ));
      notifyListeners();
    }
  }

  Future<void> addSkill(PortfolioSkill skill) async {
    if (_userId == null) {
      _skills.add(PortfolioSkill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: skill.name,
        level: skill.level,
        colorValue: skill.colorValue,
      ));
      notifyListeners();
      return;
    }
    try {
      final docRef = await _firestore.collection('users').doc(_userId).collection('portfolio').doc('data').collection('skills').add(skill.toFirestore());
      _skills.add(PortfolioSkill(
        id: docRef.id,
        name: skill.name,
        level: skill.level,
        colorValue: skill.colorValue,
      ));
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding skill: $e");
      _skills.add(PortfolioSkill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: skill.name,
        level: skill.level,
        colorValue: skill.colorValue,
      ));
      notifyListeners();
    }
  }

  Future<void> addAward(PortfolioAward award) async {
    if (_userId == null) {
      _awards.add(PortfolioAward(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: award.title,
        description: award.description,
        iconCode: award.iconCode,
      ));
      notifyListeners();
      return;
    }
    try {
      final docRef = await _firestore.collection('users').doc(_userId).collection('portfolio').doc('data').collection('awards').add(award.toFirestore());
      _awards.add(PortfolioAward(
        id: docRef.id,
        title: award.title,
        description: award.description,
        iconCode: award.iconCode,
      ));
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding award: $e");
      _awards.add(PortfolioAward(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: award.title,
        description: award.description,
        iconCode: award.iconCode,
      ));
      notifyListeners();
    }
  }
}
