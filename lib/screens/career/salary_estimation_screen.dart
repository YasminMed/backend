import 'package:flutter/material.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/constants/app_text_styles.dart';

import 'package:provider/provider.dart';
import 'package:skillora/providers/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salary Estimation',
      home: Scaffold(body: SafeArea(child: SalaryEstimationWidget())),
    );
  }
}

class SalaryEstimationWidget extends StatefulWidget {
  const SalaryEstimationWidget({super.key});

  @override
  State<SalaryEstimationWidget> createState() => _SalaryEstimationWidgetState();
}

class _SalaryEstimationWidgetState extends State<SalaryEstimationWidget> {
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _certificationsController =
      TextEditingController();
  final TextEditingController _projectsController = TextEditingController();

  double? _estimatedSalary;

  void _calculateSalary() {
    int experience = int.tryParse(_experienceController.text) ?? 0;
    int skills = _skillsController.text.isEmpty
        ? 0
        : _skillsController.text.split(',').length;
    int educationLevel = int.tryParse(_educationController.text) ?? 0;
    int certifications = _certificationsController.text.isEmpty
        ? 0
        : _certificationsController.text.split(',').length;
    int projects = int.tryParse(_projectsController.text) ?? 0;

    double salary =
        2000 +
        (experience * 300) +
        (skills * 200) +
        (educationLevel * 400) +
        (certifications * 250) +
        (projects * 150);

    setState(() {
      _estimatedSalary = salary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: AppColors.getBackgroundColor(context),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.getMainColor(context),
                      AppColors.getSecondaryColor(context),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Salary Estimator',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 20,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    _buildInputField(
                      'Years of Experience',
                      _experienceController,
                      '0',
                    ),
                    _buildInputField(
                      'Skills (comma separated)',
                      _skillsController,
                      'Flutter, Python',
                    ),
                    _buildInputField(
                      'Education Level (1-5)',
                      _educationController,
                      '3',
                    ),
                    _buildInputField(
                      'Certifications (comma separated)',
                      _certificationsController,
                      'Google, AWS',
                    ),
                    _buildInputField(
                      'Number of Projects',
                      _projectsController,
                      '0',
                    ),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculateSalary,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.getMainColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Calculate Salary',
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    if (_estimatedSalary != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.getMainColor(context),
                              AppColors.getSecondaryColor(context),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getMainColor(
                                context,
                              ).withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Estimated Salary',
                              style: TextStyle(
                                color: AppColors.getTextColor(context),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              '\$${_estimatedSalary!.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.getTextColor(context),
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: AppColors.getMainColor(context),
            fontSize: 16,
          ),
          filled: true,
          fillColor: AppColors.getSurfaceColor(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
