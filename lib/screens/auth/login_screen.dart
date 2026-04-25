import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _firebaseEmailError;
  String? _firebasePasswordError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _firebaseEmailError = null;
      _firebasePasswordError = null;
    });

    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final errorCode = await authProvider.logInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (errorCode == null) {
        Navigator.pushReplacementNamed(context, '/modes');
      } else {
        setState(() {
          if (errorCode == 'user-not-found') {
            _firebaseEmailError = 'No user found for that email.';
          } else if (errorCode == 'invalid-email') {
            _firebaseEmailError = 'Invalid email address.';
          } else if (errorCode == 'wrong-password') {
            _firebasePasswordError = 'Incorrect password.';
          } else if (errorCode == 'invalid-credential' ||
              errorCode == 'INVALID_LOGIN_CREDENTIALS') {
            _firebaseEmailError = 'Invalid login credentials.';
            _firebasePasswordError = 'Invalid login credentials.';
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login failed: $errorCode'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
        _formKey.currentState!
            .validate(); // trigger UI to show the new error text
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  //back btn
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: textColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  //title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Log In",
                          style: AppTextStyles.h1.copyWith(
                            color: textColor,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Welcome back!",
                          style: AppTextStyles.secondary.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  //white card
                  Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppColors.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.getMainColor(
                            context,
                          ).withValues(alpha: 0.5),
                          spreadRadius: 1,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        //email
                        Text(
                          "Email",
                          style: AppTextStyles.secondary.copyWith(
                            color: textColor,
                          ),
                        ),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(context),
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
                            color: textColor,
                          ),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(context).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: isDark ? Colors.white60 : Colors.grey,
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
                            return null; // we rely on Firebase for incorrect password
                          },
                        ),
                        const SizedBox(height: 12),

                        //forgot pass
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/forgot_password');
                            },
                            child: Text(
                              "Forgot Password?",
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.getMainColor(context),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),

                        /// login btn
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
                            onPressed: isLoading ? null : _handleLogin,
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
                                    "Login",
                                    style: AppTextStyles.button.copyWith(
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        //signup link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don’t have an account? ",
                              style: AppTextStyles.small.copyWith(
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(
                                "Sign up",
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
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(
      context,
      listen: false,
    ).isDarkMode;
    return InputDecoration(
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
      hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
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
