import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _firebaseEmailError;
  String? _firebasePasswordError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    setState(() {
      _firebaseEmailError = null;
      _firebasePasswordError = null;
    });

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final errorCode = await authProvider.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (errorCode == null) {
        _showSuccessPopup(context);
      } else {
        setState(() {
          if (errorCode == 'email-already-in-use') {
            _firebaseEmailError = 'Email already registered';
          } else if (errorCode == 'invalid-email') {
            _firebaseEmailError = 'Invalid email address.';
          } else if (errorCode == 'weak-password') {
            _firebasePasswordError = 'Password is too weak.';
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sign up failed: $errorCode'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
        _formKey.currentState!.validate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // back btn
                IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: AppColors.getTextColor(context)),
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(height: 10),

                /// title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sign Up",
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.getTextColor(context),
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Create new account",
                        style: AppTextStyles.secondary.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // white card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 30,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    color: AppColors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.getMainColor(context).withValues(alpha: 0.4),
                      width: 1.4,
                    ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //email
                      Text(
                        "Email",
                        style: AppTextStyles.secondary.copyWith(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(),
                        onChanged: (val) {
                          if (_firebaseEmailError != null) {
                            setState(() => _firebaseEmailError = null);
                            _formKey.currentState?.validate();
                          }
                        },
                        validator: (value) {
                          if (_firebaseEmailError != null) {
                            return _firebaseEmailError;
                          }
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          // Basic email validation regex
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email format';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),

                      /// Password
                      Text(
                        "Password",
                        style: AppTextStyles.secondary.copyWith(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration().copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        onChanged: (val) {
                          if (_firebasePasswordError != null) {
                            setState(() => _firebasePasswordError = null);
                            _formKey.currentState?.validate();
                          }
                        },
                        validator: (value) {
                          if (_firebasePasswordError != null) {
                            return _firebasePasswordError;
                          }
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),

                      //confirm pass
                      Text(
                        "Confirm Password",
                        style: AppTextStyles.secondary.copyWith(
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: _inputDecoration().copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please verify your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 40),

                      //create acc btn
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
                          onPressed: isLoading ? null : _handleSignUp,
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Create Account",
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      //login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.getTextColor(context),
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              "Log in",
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.getMainColor(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// popup sucess window
  void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,

      barrierDismissible: false, // user cannot dismiss manually
      builder: (context) {
        return Dialog(
          backgroundColor: (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // lottie success
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Lottie.asset("assets/lottie/Check.json"),
                ),

                const SizedBox(height: 10),

                // txt
                Text(
                  "New account created successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // delay then login screen
    Future.delayed(const Duration(seconds: 4), () {
      if (!context.mounted) return;
      Navigator.pop(context); // close popup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  InputDecoration _inputDecoration() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
