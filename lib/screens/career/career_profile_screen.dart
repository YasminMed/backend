import 'package:flutter/material.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import 'package:skillora/providers/auth_provider.dart';
import 'package:skillora/providers/activity_provider.dart';
import 'package:skillora/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class CareerProfileScreen extends StatefulWidget {
  final String? userId;
  const CareerProfileScreen({super.key, this.userId});

  @override
  State<CareerProfileScreen> createState() => _CareerProfileScreenState();
}

class _CareerProfileScreenState extends State<CareerProfileScreen> {
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
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);

    // Fetch activities
    await activityProvider.fetchActivities();

    if (widget.userId == null ||
        widget.userId == authProvider.currentUserModel?.uid) {
      await authProvider.refreshCurrentUser();
      _viewedUser = authProvider.currentUserModel;
      _isOwner = true;
    } else {
      _isOwner = false;
      _viewedUser = await authProvider.getUserData(widget.userId!);
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

    final activities = Provider.of<ActivityProvider>(context).activities;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.getBackgroundColor(context),
        body: Column(
          children: [
            // appbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.getMainColor(context),
                    AppColors.getSecondaryColor(context),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Text(
                    _isOwner ? "Career Profile" : "${userToShow.name}'s Profile",
                    style: const TextStyle(
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
                                AppColors.getAccentColor(context),
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
                              style: const TextStyle(
                                color: AppColors.white,
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

                    _sectionTitle(context, "Career Activities"),
                    if (activities.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "No career activities logged yet",
                          style: TextStyle(color: AppColors.grey),
                        ),
                      )
                    else
                      ...activities.map(
                        (a) => _buildActivityItem(context, a),
                      ),

                    const SizedBox(height: 20),

                    _sectionTitle(context, "Medals & Rewards"),
                    if (userToShow.medalUrls.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
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
                        icon: Icons.school,
                        text: "Switch to Study Mode",
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

  Widget _buildActivityItem(BuildContext context, CareerActivity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.getMainColor(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(activity.icon, color: AppColors.getMainColor(context), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: activity.progress / 100,
                    backgroundColor: AppColors.grey.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.getMainColor(context)),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "${activity.progress}%",
            style: TextStyle(
              color: AppColors.getMainColor(context),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalsGrid(BuildContext context, UserModel user) {
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
        bool isNetwork =
            url.startsWith('http') ||
            url.startsWith('https') ||
            (kIsWeb && url.startsWith('blob:'));

        bool isLocal = false;
        if (!kIsWeb && !isNetwork) {
          try {
            isLocal = File(url).existsSync();
          } catch (_) {
            isLocal = false;
          }
        }

        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.getAccentColor(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.getAccentColor(context).withValues(alpha: 0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: isNetwork
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
                    : kIsWeb
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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.addMedal(image.path);
        _loadUserInfo();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Medal added successfully!")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
      }
    }
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.getMainColor(context),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

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
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.softGreen.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.getAccentColor(context), AppColors.getMainColor(context)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.white,
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
    );
  }

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
          backgroundColor: AppColors.getSurfaceColor(context),
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
            style: TextStyle(color: AppColors.getTextColor(context)),
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

  // Edit Profile Sheets
  void _editNameSheet(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    _showEditSheet(
      context,
      title: "Edit Name",
      controller: nameController,
      label: "Full Name",
      onSave: () async {
        if (nameController.text.isNotEmpty) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.updateName(nameController.text.trim());
          _loadUserInfo();
        }
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
      backgroundColor: AppColors.getSurfaceColor(context),
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
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.getMainColor(context),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setModalState(() {
                                  isUpdating = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: ${e.toString()}")),
                                );
                              }
                            }
                          }
                        },
                        child: Text("Update Email", style: AppTextStyles.button),
                      ),
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
    _showEditSheet(
      context,
      title: "Edit Phone Number",
      controller: phoneController,
      label: "Phone Number",
      onSave: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.updatePhoneNumber(phoneController.text.trim());
        _loadUserInfo();
      },
    );
  }

  void _editLinkedinSheet(BuildContext context, UserModel user) {
    final linkedinController = TextEditingController(text: user.linkedinUrl);
    _showEditSheet(
      context,
      title: "Edit LinkedIn",
      controller: linkedinController,
      label: "LinkedIn Profile URL",
      onSave: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.updateLinkedinUrl(linkedinController.text.trim());
        _loadUserInfo();
      },
    );
  }

  void _editPasswordSheet(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isUpdating = false;
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getSurfaceColor(context),
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
                      labelText: "Current Password",
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
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm ? Icons.visibility_off : Icons.visibility,
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.getMainColor(context),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (newPasswordController.text == confirmPasswordController.text &&
                              newPasswordController.text.isNotEmpty) {
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
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setModalState(() {
                                  isUpdating = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: ${e.toString()}")),
                                );
                              }
                            }
                          }
                        },
                        child: Text("Update Password", style: AppTextStyles.button),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditSheet(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    required String label,
    required VoidCallback onSave,
    bool isPassword = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.getSurfaceColor(context),
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
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getMainColor(context),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onSave();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getMainColor(context),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Save Changes", style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
