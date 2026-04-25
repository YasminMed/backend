import 'package:flutter/material.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/screens/career/career_dashboard_screen.dart';
import 'package:skillora/screens/career/job_finder_screen.dart';
import 'package:skillora/screens/career/portfolio_screen.dart';
import 'package:skillora/screens/career/career_chatbot_screen.dart';
import 'package:skillora/screens/career/career_roadmap_screen.dart';
import 'package:skillora/screens/career/careert_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:skillora/providers/career_nav_provider.dart';

//import navbar

class CareerMainLayout extends StatelessWidget {
  const CareerMainLayout({super.key});

  // screens map
  Widget _getScreen(String tab) {
    switch (tab) {
      case "jobs":
        return PastelJobFinderWidget();
      case "portfolio":
        return PortfolioScreen();
      case "chatbot":
        return CareerChatbotScreen();
      case "roadmap":
        return CareerRoadmapScreenWidget();
      default:
        return CareerDashboardWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CareerNavProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.getBackgroundColor(context),
          body: _getScreen(navProvider.activeTab),
          bottomNavigationBar: CareerBottomNavBar(
            activeTab: navProvider.activeTab,
            onTabChange: (tabId) => navProvider.setTab(tabId),
          ),
        );
      },
    );
  }
}
