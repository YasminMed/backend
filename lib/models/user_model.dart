class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String linkedinUrl;
  final List<String> registeredCourseIds;
  final List<String> medalUrls;
  final Map<String, dynamic> courseProgress; // Key: courseId, Value: {progress, hours, completedWeeks}
  final String? fcmToken;
  final String? role; // 'student' or 'worker'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.linkedinUrl = '',
    required this.registeredCourseIds,
    required this.medalUrls,
    this.courseProgress = const {},
    this.fcmToken,
    this.role,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber']?.toString() ?? '',
      linkedinUrl: data['linkedinUrl'] ?? '',
      registeredCourseIds: (data['registeredCourseIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      medalUrls: (data['medalUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      courseProgress: data['courseProgress'] as Map<String, dynamic>? ?? {},
      fcmToken: data['fcmToken'] as String?,
      role: data['role'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'linkedinUrl': linkedinUrl,
      'registeredCourseIds': registeredCourseIds,
      'medalUrls': medalUrls,
      'courseProgress': courseProgress,
      'fcmToken': fcmToken,
      'role': role,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? linkedinUrl,
    List<String>? registeredCourseIds,
    List<String>? medalUrls,
    Map<String, dynamic>? courseProgress,
    String? fcmToken,
    String? role,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      registeredCourseIds: registeredCourseIds ?? this.registeredCourseIds,
      medalUrls: medalUrls ?? this.medalUrls,
      courseProgress: courseProgress ?? this.courseProgress,
      fcmToken: fcmToken ?? this.fcmToken,
      role: role ?? this.role,
    );
  }
}
