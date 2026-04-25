import 'dart:convert';
import 'dart:math';
import 'dart:typed_data'; // Added for Uint8List
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUserModel;
  UserModel? get currentUserModel => _currentUserModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchUserData(user.uid);
      } else {
        _currentUserModel = null;
        notifyListeners();
      }
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch user data from Firestore
  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final user = _auth.currentUser;
      
      if (doc.exists) { // if user existed
        UserModel model = UserModel.fromFirestore(doc.data()!, uid); //convert json yo dart
        if (user != null && user.uid == uid) {
          model = model.copyWith(email: user.email ?? model.email); //prioritize auth email or fallback to firestore
        }
        _currentUserModel = model;
      } else {
        // new signup / incomplete data
        if (user != null) {
          _currentUserModel = UserModel( //create default user
            uid: uid,
            name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
            email: user.email ?? '',
            registeredCourseIds: [],
            medalUrls: [],
          );
          //save to database
          await _firestore.collection('users').doc(uid).set(_currentUserModel!.toFirestore());
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  // Fetch any user data (for public profile viewing) / view other profiles
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, uid);
      }
    } catch (e) {
      debugPrint('Error getting user data: $e');
    }
    return null;
  }

  //fetch all useres except current
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      List<UserModel> users = [];
      for (var doc in snapshot.docs) {
        try {
          if (doc.id == _auth.currentUser?.uid) continue; //skip yourself
          users.add(UserModel.fromFirestore(doc.data(), doc.id));
        } catch (e) {
          debugPrint('Error parsing user ${doc.id}: $e');
        }
      }
      return users;
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }

  // Update user name
  Future<void> updateName(String name) async {
    if (_currentUserModel == null) return;
    _setLoading(true);
    try {
      await _firestore.collection('users').doc(_currentUserModel!.uid).update({
        'name': name,
      });
      _currentUserModel = _currentUserModel!.copyWith(name: name);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Update user email
  Future<void> updateEmail(String newEmail, String currentPassword) async {
    if (_currentUserModel == null || _auth.currentUser == null) return;
    _setLoading(true);
    try {
      // Re-authenticate first using the current email in Auth
      AuthCredential credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: currentPassword,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);

      // 1. Update in Firebase Auth FIRST
      await _auth.currentUser!.verifyBeforeUpdateEmail(newEmail);
      await _auth.currentUser!.reload();

      // VERIFICATION: Check if the email actually changed in Firebase Auth
      // Firebase sometimes requires verification before fully applying the change
      final updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser != null && updatedUser.email == newEmail) {
        // 2. Update in Firestore ONLY after Auth successfully reflects the change
        await _firestore.collection('users').doc(_currentUserModel!.uid).update({
          'email': newEmail,
        });

        // Update local state
        _currentUserModel = _currentUserModel!.copyWith(email: newEmail);
        notifyListeners();
      } else {
        // If the email didn't change (e.g. pending verification), notify the user
        throw FirebaseAuthException(
          code: 'verification-required',
          message: 'Please verify your new email before the change can be finalized and synchronized.',
        );
      }
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Refresh user data manually
  Future<void> refreshCurrentUser() async {
    if (_auth.currentUser == null) return;
    await fetchUserData(_auth.currentUser!.uid);
  }

  // Update user phone
  Future<void> updatePhoneNumber(String phone) async {
    if (_currentUserModel == null) return;
    _setLoading(true);
    try {
      await _firestore.collection('users').doc(_currentUserModel!.uid).update({
        'phoneNumber': phone,
      });
      _currentUserModel = _currentUserModel!.copyWith(phoneNumber: phone);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Update LinkedIn
  Future<void> updateLinkedinUrl(String url) async {
    if (_currentUserModel == null) return;
    _setLoading(true);
    try {
      await _firestore.collection('users').doc(_currentUserModel!.uid).update({
        'linkedinUrl': url,
      });
      _currentUserModel = _currentUserModel!.copyWith(linkedinUrl: url);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Change Password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (_auth.currentUser == null) return;
    _setLoading(true);
    try {
      // Re-authenticate
      AuthCredential credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: oldPassword,
      );
      await _auth.currentUser!.reauthenticateWithCredential(credential);
      // Update password
      await _auth.currentUser!.updatePassword(newPassword);
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    if (_auth.currentUser == null || _currentUserModel == null) return;
    _setLoading(true);
    try {
      String uid = _currentUserModel!.uid;
      // Delete from Firestore first
      await _firestore.collection('users').doc(uid).delete();
      // Delete from Auth
      await _auth.currentUser!.delete();
      _currentUserModel = null;
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Update medals
  Future<void> addMedal(String medalUrl) async {
    if (_currentUserModel == null) return;
    try {
      final updatedMedals = List<String>.from(_currentUserModel!.medalUrls)
        ..add(medalUrl);
      await _firestore.collection('users').doc(_currentUserModel!.uid).update({
        'medalUrls': updatedMedals,
      });
      _currentUserModel = _currentUserModel!.copyWith(medalUrls: updatedMedals);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding medal: $e');
    }
  }

  // Clear all medals
  Future<void> clearMedals() async {
    if (_currentUserModel == null) return;
    try {
      await _firestore.collection('users').doc(_currentUserModel!.uid).update({
        'medalUrls': [],
      });
      _currentUserModel = _currentUserModel!.copyWith(medalUrls: []);
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing medals: $e');
    }
  }

  // Remove specific medal
  Future<void> removeMedalAt(int index) async {
    if (_currentUserModel == null) return;
    try {
      final updatedMedals = List<String>.from(_currentUserModel!.medalUrls);
      if (index >= 0 && index < updatedMedals.length) {
        updatedMedals.removeAt(index);
        await _firestore
            .collection('users')
            .doc(_currentUserModel!.uid)
            .update({'medalUrls': updatedMedals});
        _currentUserModel = _currentUserModel!.copyWith(medalUrls: updatedMedals);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error removing medal: $e');
    }
  }

  // Register course
  Future<void> registerCourse(String courseId, {int totalWeeks = 1}) async {
    if (_currentUserModel == null) return;
    try {
      final updatedCourseIds = List<String>.from(
        _currentUserModel!.registeredCourseIds,
      )..add(courseId);

      // Initialize progress entry for this course
      final updatedProgress = Map<String, dynamic>.from(_currentUserModel!.courseProgress);
      updatedProgress[courseId] = {
        'progress': 0,
        'hours': 0.0,
        'completedWeeks': List.filled(totalWeeks, false),
      };

      await _firestore.collection('users').doc(_currentUserModel!.uid).update({
        'registeredCourseIds': updatedCourseIds,
        'courseProgress': updatedProgress,
      });

      _currentUserModel = _currentUserModel!.copyWith(
        registeredCourseIds: updatedCourseIds,
        courseProgress: updatedProgress,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error registering course: $e');
    }
  }

  // Unregister course
  Future<void> unregisterCourse(String courseId) async {
    if (_currentUserModel == null) return;
    try {
      final updatedCourseIds = List<String>.from(
        _currentUserModel!.registeredCourseIds,
      )..remove(courseId);

      // Remove progress entry
      final updatedProgress = Map<String, dynamic>.from(_currentUserModel!.courseProgress);
      updatedProgress.remove(courseId);

      await _firestore.collection('users').doc(_currentUserModel!.uid).update({
        'registeredCourseIds': updatedCourseIds,
        'courseProgress': updatedProgress,
      });

      _currentUserModel = _currentUserModel!.copyWith(
        registeredCourseIds: updatedCourseIds,
        courseProgress: updatedProgress,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error unregistering course: $e');
    }
  }

  // Update specific course data (progress, hours, completedWeeks)
  Future<void> updateUserCourseData(String courseId, Map<String, dynamic> data) async {
    if (_currentUserModel == null) return;
    try {
      final updatedProgress = Map<String, dynamic>.from(_currentUserModel!.courseProgress);
      
      // Merge new data with existing data for this course
      final currentCourseData = updatedProgress[courseId] as Map<String, dynamic>? ?? {};
      updatedProgress[courseId] = {...currentCourseData, ...data};

      await _firestore.collection('users').doc(_currentUserModel!.uid).update({
        'courseProgress': updatedProgress,
      });

      _currentUserModel = _currentUserModel!.copyWith(courseProgress: updatedProgress);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user course data: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<String?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _setLoading(true);
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      final newUser = UserModel(
        uid: credential.user!.uid,
        name: email.split('@')[0],
        email: email,
        phoneNumber: '',
        linkedinUrl: '',
        registeredCourseIds: [],
        medalUrls: [],
        courseProgress: {},
      );
      await _firestore
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toFirestore());
      _currentUserModel = newUser;

      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.code;
    } catch (e) {
      _setLoading(false);
      return 'unknown-error';
    }
  }

  // Log in with email and password
  Future<String?> logInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _setLoading(true);
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await fetchUserData(credential.user!.uid);
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return e.code;
    } catch (e) {
      _setLoading(false);
      return 'unknown-error';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUserModel = null;
    notifyListeners();
  }

  // Send Password Reset Code (using Google Apps Script)
  Future<void> sendPasswordResetCode(String email) async {
    _setLoading(true);
    try {
      // 1. Generate 6-digit code
      final code = (Random().nextInt(900000) + 100000).toString();

      // 2. Send our 6-digit OTP via Google Apps Script for identity verification
      final scriptUrl = 'https://script.google.com/macros/s/AKfycbzhf0QRmAKj-yEQJW4KXEyNY0QJ2nZ8qFEZ-7hHOqB5pqVkvDQFZufuiHKMEm6DHkyr7Q/exec';
      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode({
          'type': 'email',
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 302) {
        throw Exception('Failed to send email via Google Script: ${response.statusCode}');
      }

      // 3. Store code in Firestore with expiration (15 mins)
      await _firestore.collection('password_resets').doc(email).set({
        'otp': code,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt':
            DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch,
        'isVerified': false,
      });

      debugPrint('Reset code for $email: $code');
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Verify Password Reset Code
  Future<bool> verifyPasswordResetCode(String email, String code) async {
    _setLoading(true);
    try {
      final doc = await _firestore.collection('password_resets').doc(email).get();
      if (!doc.exists) {
        _setLoading(false);
        return false;
      }

      final data = doc.data()!;
      final storedOtp = data['otp'];
      final expiresAt = data['expiresAt'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
        _setLoading(false);
        throw Exception('Code expired.');
      }

      if (storedOtp == code) {
        await _firestore.collection('password_resets').doc(email).update({
          'isVerified': true,
        });
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Convert image to base64 data URL (works on both Web and Mobile without CORS issues)
  Future<String> uploadImageToDrive(Uint8List bytes, String filename) async {
    try {
      final base64Image = base64Encode(bytes);
      final extension = filename.split('.').last.toLowerCase();
      final mimeType = extension == 'jpg' ? 'image/jpeg' : 'image/$extension';
      // Create a data URL - stored directly in Firestore, no external service needed
      // This avoids all CORS/authentication issues with Google Drive on web browsers
      final dataUrl = 'data:$mimeType;base64,$base64Image';
      return dataUrl;
    } catch (e) {
      debugPrint('Error converting image: $e');
      rethrow;
    }
  }

  // Reset Password using Google Apps Script as a privileged backend
  Future<void> resetPassword(String email, String newPassword) async {
    _setLoading(true);
    try {
      // 1. Verify OTP was confirmed in Firestore (security check)
      final doc = await _firestore.collection('password_resets').doc(email).get();
      if (!doc.exists || doc.data()!['isVerified'] != true) {
        throw Exception('Verification required. Please verify your code first.');
      }

      // 2. Call Google Apps Script to perform the administrative password update
      final scriptUrl = 'https://script.google.com/macros/s/AKfycbzhf0QRmAKj-yEQJW4KXEyNY0QJ2nZ8qFEZ-7hHOqB5pqVkvDQFZufuiHKMEm6DHkyr7Q/exec';
      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode({
          'type': 'reset',
          'email': email,
          'newPassword': newPassword,
        }),
      );

      _setLoading(false);

      if (response.statusCode != 200 && response.statusCode != 302) {
        throw Exception('Server returned error: ${response.statusCode}');
      }

      // Safe JSON parsing to avoid FormatException on HTML error pages
      Map<String, dynamic> result;
      try {
        result = jsonDecode(response.body);
      } catch (e) {
        debugPrint("GAS Response Body: ${response.body}");
        throw Exception('Invalid server response. Please ensure your Google Script is deployed as "Anyone".');
      }

      if (result['status'] == 'error') {
        throw Exception(result['message'] ?? 'Failed to reset password');
      }

      // 3. Cleanup: Delete the reset request from Firestore
      await _firestore.collection('password_resets').doc(email).delete();
      
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  // Set user role (student or worker)
  Future<void> setUserRole(String role) async {
    if (_currentUserModel == null) return;
    try {
      await _firestore.collection('users').doc(_currentUserModel!.uid).update({
        'role': role,
      });
      _currentUserModel = _currentUserModel!.copyWith(role: role);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting user role: $e');
    }
  }
}
