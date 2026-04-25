import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class InfoContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const InfoContentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.getMainColor(context), AppColors.accent],
            ),
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.getMainColor(
                context,
              ).withValues(alpha: isDarkMode ? 0.05 : 0.15),
              isDarkMode ? const Color(0xFF121212) : AppColors.white,
              AppColors.accent.withValues(alpha: isDarkMode ? 0.05 : 0.10),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black26
                      : AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              content,
              style: AppTextStyles.body.copyWith(
                color: isDarkMode ? AppColors.white : Colors.black87,
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
