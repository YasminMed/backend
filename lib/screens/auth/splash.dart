import 'dart:async';
import 'package:flutter/material.dart';
import 'package:skillora/constants/app_colors.dart';

class SkilloraSplashScreen extends StatefulWidget {
  const SkilloraSplashScreen({super.key});

  @override
  State<SkilloraSplashScreen> createState() => _SkilloraSplashScreenState();
}

class _SkilloraSplashScreenState extends State<SkilloraSplashScreen> {
  final PageController _controller = PageController();
  late Timer _timer;
  int _currentIndex = 0;

  final List<Map<String, String>> splashData = [
    {
      "image": "assets/images/splash_1.png",
      "title": "Track Your Study Journey",
      "text":
          "Stay organized and monitor your progress with smooth and smart tools.",
    },
    {
      "image": "assets/images/splash_2.png",
      "title": "Build Your Career Path",
      "text":
          "Discover courses, improve your skills, and shape your professional future.",
    },
    {
      "image": "assets/images/splash_3.png",
      "title": "Achieve Your Academic Goals",
      "text":
          "Set goals, stay motivated, and progress through your learning roadmap.",
    },
  ];

  @override
  void initState() {
    super.initState();

    // auto slider
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!mounted) return; // screen doesnt exist

      if (_controller.hasClients) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % splashData.length; // loop
        });

        _controller.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // stop the timer
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),

            // SLIDER
            Expanded(
              flex: 6,
              child: PageView.builder(
                controller: _controller,
                itemCount: splashData.length,
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() => _currentIndex = index);
                  }
                },
                physics: BouncingScrollPhysics(),
                itemBuilder: (_, index) {
                  return Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.getMainColor(
                                      context,
                                    ).withValues(alpha: 0.15),
                                    AppColors.accent.withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Image.asset(
                                splashData[index]["image"]!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // DOTs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                splashData.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 8,
                  width: _currentIndex == index ? 28 : 10,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppColors.getMainColor(context)
                        : AppColors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            SizedBox(height: 30),

            //txt
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Text(
                    splashData[_currentIndex]["title"]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.getMainColor(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    splashData[_currentIndex]["text"]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.getSurfaceColor(
                        context,
                      ).withValues(alpha: 0.85),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // btn
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getMainColor(context),
                  minimumSize: Size(double.infinity, 55),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: Text(
                  "Create account",
                  style: TextStyle(
                    color: AppColors.getSurfaceColor(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}
