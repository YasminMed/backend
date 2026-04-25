import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.getMainColor(context),
              AppColors.accent.withValues(alpha: 0.2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.30],
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            /// logo
            Image.asset("assets/images/logo.png", width: 150, height: 150),

            const SizedBox(height: 40),

            /// title
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "welcome to ",
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.getTextColor(context),
                      shadows: const [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  TextSpan(
                    text: "Skillora",
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.getMainColor(context),
                      shadows: const [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 4,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Container(
              width: 200,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.getMainColor(context).withValues(alpha: 0.2),

                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 16,
                      color: AppColors.getMainColor(context),
                    ),
                    Text(
                      "Start your journey here",
                      style: AppTextStyles.secondary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 200),

            /// btn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
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
                  onPressed: () {
                    Navigator.pushNamed(context, '/splash');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Get Started", style: AppTextStyles.button),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.getSurfaceColor(context),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
