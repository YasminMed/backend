import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:skillora/providers/auth_provider.dart';
import 'package:skillora/providers/course_provider.dart';
import 'package:skillora/models/user_model.dart';
import 'package:skillora/models/course_model.dart' as model;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert'; // for base64Decode

class StudyProfileWidget extends StatefulWidget {
  final String? userId;
  const StudyProfileWidget({super.key, this.userId});

  @override
  State<StudyProfileWidget> createState() => _StudyProfileWidgetState();
}

class _StudyProfileWidgetState extends State<StudyProfileWidget> {
  UserModel? _viewedUser;
  bool _isOwner = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserInfo();
    });
  }

  Future<void> _loadUserInfo() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    // Safety: ensure courses are fetched
    if (courseProvider.courses.isEmpty) {
      await courseProvider.fetchCourses();
    }

    if (widget.userId == null ||
        widget.userId == authProvider.currentUserModel?.uid) {
      await authProvider.refreshCurrentUser();
      _viewedUser = authProvider.currentUserModel;
      _isOwner = true;
    } else {
      _isOwner = false;
      _viewedUser = await authProvider.getUserData(widget.userId!);
    }

    // After getting user, ensure courses are synced with their registration
    if (_viewedUser != null) {
      await courseProvider.fetchCourses();
    }

    _isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final authProvider = Provider.of<AuthProvider>(context);
    final userToShow = _isOwner ? authProvider.currentUserModel : _viewedUser;

    if (userToShow == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    final courses = Provider.of<CourseProvider>(context).courses;
    final registeredCourses = courses
        .where((c) => userToShow.registeredCourseIds.contains(c.id))
        .toList();

    return SafeArea(
      child: Material(
        color: AppColors.getSurfaceColor(context),
        child: Column(
          children: [
            // appbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.getMainColor(context),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.getSurfaceColor(context),
                      ),
                    ),
                  ),
                  Text(
                    _isOwner ? "My Profile" : "${userToShow.name}'s Profile",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Avatar + Name
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.getMainColor(context),
                                AppColors.accent,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.getMainColor(
                                  context,
                                ).withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              userToShow.name.isNotEmpty
                                  ? userToShow.name[0].toUpperCase()
                                  : "?",
                              style: TextStyle(
                                color: AppColors.getSurfaceColor(context),
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userToShow.name,
                          style: TextStyle(
                            color: AppColors.getTextColor(
                              context,
                            ).withValues(alpha: 0.87),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userToShow.email,
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 14,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              userToShow.phoneNumber.isNotEmpty
                                  ? userToShow.phoneNumber
                                  : "Not provided",
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.link,
                              size: 14,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              userToShow.linkedinUrl.isNotEmpty
                                  ? userToShow.linkedinUrl
                                  : "Not provided",
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _sectionTitle(context, "Registered Courses"),
                    if (registeredCourses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "No courses registered yet",
                          style: TextStyle(color: AppColors.grey),
                        ),
                      )
                    else
                      ...registeredCourses.map(
                        (c) => _buildCourseItem(context, c),
                      ),

                    const SizedBox(height: 20),

                    _sectionTitle(context, "Medals & Rewards"),
                    if (userToShow.medalUrls.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "No medals earned yet",
                          style: TextStyle(color: AppColors.grey),
                        ),
                      )
                    else
                      _buildMedalsGrid(context, userToShow),

                    if (_isOwner) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _uploadMedal(context),
                              icon: const Icon(Icons.upload, size: 18),
                              label: const Text("Upload Medal"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.getMainColor(
                                  context,
                                ),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          if (userToShow.medalUrls.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                _confirmAction(
                                  context,
                                  title: "Remove Medals",
                                  message:
                                      "Are you sure you want to remove all existing medals?",
                                  onYes: () async {
                                    await authProvider.clearMedals();
                                    _loadUserInfo();
                                  },
                                );
                              },
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text("Remove All"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.withValues(alpha: 0.1),
                                foregroundColor: Colors.red,
                                elevation: 0,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],

                    if (_isOwner) ...[
                      const SizedBox(height: 24),
                      _sectionTitle(context, "Account Settings"),
                      _profileAction(
                        context,
                        icon: Icons.person,
                        text: "Edit Profile Name",
                        color: AppColors.getTextColor(context),
                        onTap: () => _editNameSheet(context, userToShow),
                      ),
                      _profileAction(
                        context,
                        icon: Icons.email,
                        text: "Edit Email",
                        color: AppColors.getTextColor(context),
                        onTap: () => _editEmailSheet(context, userToShow),
                      ),
                      _profileAction(
                        context,
                        icon: Icons.phone,
                        text: "Edit Phone Number",
                        color: AppColors.getTextColor(context),
                        onTap: () => _editPhoneSheet(context, userToShow),
                      ),
                      _profileAction(
                        context,
                        icon: Icons.link,
                        text: "Edit LinkedIn",
                        color: AppColors.getTextColor(context),
                        onTap: () => _editLinkedinSheet(context, userToShow),
                      ),
                      _profileAction(
                        context,
                        icon: Icons.lock,
                        text: "Change Password",
                        color: AppColors.getTextColor(context),
                        onTap: () => _editPasswordSheet(context),
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(context, "Navigation"),
                      _profileAction(
                        context,
                        icon: Icons.route,
                        text: "Switch to Career Path",
                        color: AppColors.getTextColor(context),
                        onTap: () => Navigator.pushNamed(context, "/modes"),
                      ),
                      _profileAction(
                        context,
                        icon: Icons.swap_horiz,
                        text: "Switch to Another Account",
                        color: AppColors.getTextColor(context),
                        onTap: () async {
                          await authProvider.signOut();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/signup",
                              (route) => false,
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle(context, "Danger Zone"),
                      _profileAction(
                        context,
                        icon: Icons.logout,
                        text: "Logout",
                        color: Colors.red,
                        onTap: () {
                          _confirmAction(
                            context,
                            title: "Logout",
                            message: "Are you sure you want to log out?",
                            onYes: () async {
                              await authProvider.signOut();
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  "/signup",
                                  (route) => false,
                                );
                              }
                            },
                          );
                        },
                      ),
                      _profileAction(
                        context,
                        icon: Icons.delete_forever,
                        text: "Delete Account",
                        color: Colors.red.shade700,
                        onTap: () {
                          _confirmAction(
                            context,
                            title: "Delete Account",
                            message: "This action cannot be undone!",
                            onYes: () async {
                              try {
                                await authProvider.deleteAccount();
                                if (context.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    "/signup",
                                    (route) => false,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Error deleting account: $e",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem(BuildContext context, model.Course course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.softGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(course.icon, color: AppColors.getMainColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              course.title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            "${course.progress}%",
            style: TextStyle(
              color: AppColors.getMainColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalsGrid(BuildContext context, UserModel user) {
    if (user.medalUrls.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            "No medals or rewards yet",
            style: TextStyle(color: AppColors.grey),
          ),
        ),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isMe = authProvider.currentUserModel?.uid == user.uid;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: user.medalUrls.length,
      itemBuilder: (context, index) {
        final url = user.medalUrls[index];
        final bool isDataUrl = url.startsWith('data:');
        bool isNetwork =
            !isDataUrl &&
            (url.startsWith('http') ||
            url.startsWith('https') ||
            (kIsWeb && url.startsWith('blob:')));

        // Safety check for File access on web
        bool isLocal = false;
        if (!kIsWeb && !isNetwork && !isDataUrl) {
          try {
            isLocal = File(url).existsSync();
          } catch (_) {
            isLocal = false;
          }
        }

        // Decode base64 data URL to bytes
        Uint8List? imageBytes;
        if (isDataUrl) {
          try {
            final base64Str = url.split(',').last;
            imageBytes = base64Decode(base64Str);
          } catch (_) {
            imageBytes = null;
          }
        }

        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: isDataUrl && imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                      )
                    : isNetwork
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                      )
                    : (!kIsWeb && isLocal)
                    ? Image.file(
                        File(url),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.workspace_premium,
                          color: Colors.amber,
                        ),
                      ),
              ),
            ),
            if (isMe)
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () {
                    _confirmAction(
                      context,
                      title: "Delete Medal",
                      message: "Are you sure you want to remove this medal?",
                      onYes: () async {
                        await authProvider.removeMedalAt(index);
                        _loadUserInfo();
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _uploadMedal(BuildContext context) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && context.mounted) {
        setState(() => _isLoading = true);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // 1. Upload to Google Drive (via Apps Script)
        final Uint8List bytes = await image.readAsBytes();
        final String filename = image.name;
        final permanentUrl = await authProvider.uploadImageToDrive(bytes, filename);
        
        // 2. Add the permanent URL to Firestore
        await authProvider.addMedal(permanentUrl);
        
        await _loadUserInfo();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Medal uploaded and saved permanently!")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error uploading image: $e")));
      }
    }
  }

  // sec title
  Widget _sectionTitle(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.getMainColor(context),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  //action tile
  Widget _profileAction(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  AppColors.getSurfaceColor(context),
                  AppColors.getSurfaceColor(context),
                ]
              : [
                  AppColors.getSurfaceColor(context),
                  AppColors.softGreen.withValues(alpha: 0.15),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.getMainColor(context)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : AppColors.getSurfaceColor(context)),
              size: 20,
            ),
          ),
          title: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ),
      ),
    );
  }

  // confirm dialog
  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onYes,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : AppColors.getSurfaceColor(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.getMainColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.getSurfaceColor(context)
                  : AppColors.darkBrown),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.grey),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(
                "Yes",
                style: TextStyle(
                  color: AppColors.getMainColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                onYes();
              },
            ),
          ],
        );
      },
    );
  }

  // bottom sheets

  void _editNameSheet(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : AppColors.getSurfaceColor(context)),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit Name",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getMainColor(context),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "New Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getMainColor(context),
                ),
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    await Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).updateName(nameController.text.trim());
                    if (context.mounted) Navigator.pop(context);
                    _loadUserInfo();
                  }
                },
                child: Text("Edit", style: AppTextStyles.button),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editEmailSheet(BuildContext context, UserModel user) {
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    bool isUpdating = false;
    bool obscurePassword = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : AppColors.getSurfaceColor(context)),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Edit Email",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getMainColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "New Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Current Password (required)",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setModalState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isUpdating)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getMainColor(context),
                      ),
                      onPressed: () async {
                        if (emailController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty) {
                          setModalState(() {
                            isUpdating = true;
                          });
                          try {
                            await Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).updateEmail(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                            if (context.mounted) {
                              Navigator.pop(modalContext);
                              _loadUserInfo();
                              showDialog(
                                context: context,
                                builder: (cntxt) => AlertDialog(
                                  backgroundColor: AppColors.getSurfaceColor(
                                    context,
                                  ),
                                  title: const Text("Success"),
                                  content: const Text("email updated"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(cntxt),
                                      child: Text(
                                        "Sure",
                                        style: TextStyle(
                                          color: AppColors.getMainColor(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            if (context.mounted) {
                              setModalState(() {
                                isUpdating = false;
                              });
                              String message =
                                  "Update failed: ${e.message ?? e.code}";
                              if (e.code == 'requires-recent-login') {
                                message =
                                    "Please log in again to change your email.";
                              } else if (e.code == 'email-already-in-use') {
                                message =
                                    "This email is already registered to another account.";
                              } else if (e.code == 'invalid-email') {
                                message = "Please enter a valid email address.";
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setModalState(() {
                                isUpdating = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Error: ${e.toString().split(']').last.trim()}",
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please enter both email and password",
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      child: Text("Update", style: AppTextStyles.button),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _editPhoneSheet(BuildContext context, UserModel user) {
    final phoneController = TextEditingController(text: user.phoneNumber);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : AppColors.getSurfaceColor(context)),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit Phone Number",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getMainColor(context),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getMainColor(context),
                ),
                onPressed: () async {
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).updatePhoneNumber(phoneController.text.trim());
                  if (context.mounted) Navigator.pop(context);
                  _loadUserInfo();
                },
                child: Text("Update", style: AppTextStyles.button),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editLinkedinSheet(BuildContext context, UserModel user) {
    final linkedinController = TextEditingController(text: user.linkedinUrl);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : AppColors.getSurfaceColor(context)),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit LinkedIn",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getMainColor(context),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkedinController,
                decoration: const InputDecoration(
                  labelText: "LinkedIn URL",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getMainColor(context),
                ),
                onPressed: () async {
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).updateLinkedinUrl(linkedinController.text.trim());
                  if (context.mounted) Navigator.pop(context);
                  _loadUserInfo();
                },
                child: Text("Update", style: AppTextStyles.button),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editPasswordSheet(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool passwordsMatch = true;
    bool isUpdating = false;
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : AppColors.getSurfaceColor(context)),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getMainColor(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: oldPasswordController,
                    obscureText: obscureOld,
                    decoration: InputDecoration(
                      labelText: "Previous Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureOld ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setModalState(() {
                            obscureOld = !obscureOld;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      border: const OutlineInputBorder(),
                      errorText: passwordsMatch ? null : "",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setModalState(() {
                            obscureNew = !obscureNew;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      border: const OutlineInputBorder(),
                      errorText: passwordsMatch
                          ? null
                          : "Passwords do not match",
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setModalState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isUpdating)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getMainColor(context),
                      ),
                      onPressed: () async {
                        if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          setModalState(() {
                            passwordsMatch = false;
                          });
                          return;
                        } else {
                          setModalState(() {
                            passwordsMatch = true;
                          });
                        }

                        setModalState(() {
                          isUpdating = true;
                        });

                        try {
                          await Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          ).changePassword(
                            oldPasswordController.text,
                            newPasswordController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.pop(modalContext);
                            _loadUserInfo();
                            showDialog(
                              context: context,
                              builder: (cntxt) => AlertDialog(
                                backgroundColor: AppColors.getSurfaceColor(
                                  context,
                                ),
                                title: const Text("Success"),
                                content: const Text("password updated"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(cntxt),
                                    child: Text(
                                      "Sure",
                                      style: TextStyle(
                                        color: AppColors.getMainColor(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setModalState(() {
                              isUpdating = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Error: ${e.toString().split(']').last.trim()}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Text("Change", style: AppTextStyles.button),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
