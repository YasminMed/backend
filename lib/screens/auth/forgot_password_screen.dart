import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  State<ForgotPasswordEmailScreen> createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF000000), const Color(0xFF121212)]
                : [AppColors.getMainColor(context), const Color(0xFFFFE6E6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.60],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // BACK btn
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.getTextColor(context),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Forgot password",
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.getTextColor(context),
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Enter your Email to recieve the code",
                        style: AppTextStyles.secondary.copyWith(
                          color: AppColors.getTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // white card
                Container(
                  height: 400,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.getMainColor(context).withValues(alpha: 0.5),
                        spreadRadius: 1,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.getMainColor(context),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.email,
                            size: 32,
                            color: AppColors.getSurfaceColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      //email
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Email",
                          style: AppTextStyles.secondary.copyWith(
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(context),
                        ),
                      ),
                      const SizedBox(height: 60),

                      //continue btn
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.getMainColor(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final email =
                                      _emailController.text.trim().toLowerCase();
                                  if (email.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Please enter your email"),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _isLoading = true);
                                  try {
                                    await context
                                        .read<AuthProvider>()
                                        .sendPasswordResetCode(email);
                                    if (context.mounted) {
                                      setState(() => _isLoading = false);
                                      Navigator.pushNamed(
                                        context,
                                        '/code_submit',
                                        arguments: email,
                                      );
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    if (context.mounted) {
                                      setState(() => _isLoading = false);
                                      final msg = e.code == 'user-not-found'
                                          ? 'No account found with this email.'
                                          : (e.message ?? "An error occurred");
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(msg),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      setState(() => _isLoading = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Failed to send code: ${e.toString()}"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Recieve",
                                  style:
                                      AppTextStyles.button.copyWith(fontSize: 15),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      //resend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't recieve code? ",
                            style: AppTextStyles.small,
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Resend",
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.getMainColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
