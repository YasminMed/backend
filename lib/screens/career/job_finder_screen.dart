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
      home: Scaffold(body: SafeArea(child: PastelJobFinderWidget())),
    );
  }
}

//appbar
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key, this.title = "Find Jobs"});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: preferredSize.height,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

//job models
class Job {
  final int id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final IconData logo;
  final String type;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.logo,
    required this.type,
  });
}

//job finder screen
class PastelJobFinderWidget extends StatefulWidget {
  const PastelJobFinderWidget({super.key});

  @override
  State<PastelJobFinderWidget> createState() => _PastelJobFinderWidgetState();
}

class _PastelJobFinderWidgetState extends State<PastelJobFinderWidget> {
  String searchQuery = '';
  String selectedFilter = 'All';
  Set<int> savedJobs = {};

  final List<String> filters = ['All', 'Full-time', 'Part-time', 'Remote'];

  final List<Job> jobs = [
    Job(
      id: 1,
      title: 'UI/UX Designer',
      company: 'Google',
      location: 'Family Mall',
      salary: '\$1k - \$900',
      logo: Icons.auto_awesome,
      type: 'Full-time',
    ),
    Job(
      id: 2,
      title: 'Frontend Developer',
      company: 'Meta',
      location: 'Remote',
      salary: '\$90k - \$140k',
      logo: Icons.terminal,
      type: 'Full-time',
    ),
    Job(
      id: 3,
      title: 'Product Manager',
      company: 'Amazon',
      location: 'Empire',
      salary: '\$20k - \$1k',
      logo: Icons.inventory_2_outlined,
      type: 'Full-time',
    ),
    Job(
      id: 4,
      title: 'Mobile Developer',
      company: 'Apple',
      location: '32Park',
      salary: '\$95k - \$135k',
      logo: Icons.phone_iphone,
      type: 'Full-time',
    ),
    Job(
      id: 5,
      title: 'Data Analyst',
      company: 'Microsoft',
      location: 'Redmond',
      salary: '\$75k - \$110k',
      logo: Icons.analytics_outlined,
      type: 'Part-time',
    ),
  ];

  void toggleSaveJob(int jobId) {
    setState(() {
      savedJobs.contains(jobId)
          ? savedJobs.remove(jobId)
          : savedJobs.add(jobId);
    });
  }

  List<Job> get filteredJobs {
    final limitedJobs = jobs.take(4).toList(); // Only 4 jobs
    return limitedJobs.where((job) {
      final searchMatch =
          job.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          job.company.toLowerCase().contains(searchQuery.toLowerCase());
      final filterMatch =
          selectedFilter == 'All' ||
          job.type == selectedFilter ||
          (selectedFilter == 'Remote' && job.location == 'Remote');
      return searchMatch && filterMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.softGreen,
        child: Column(
          children: [
            AppBarWidget(title: "Find Jobs"),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // search bar
                    SizedBox(
                      height: 42,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                              ? Color(0xFF1E1E1E)
                              : (Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white)),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Icon(Icons.search, size: 20, color: AppColors.grey),
                            SizedBox(width: 6),
                            Expanded(
                              child: TextField(
                                onChanged: (v) =>
                                    setState(() => searchQuery = v),
                                decoration: InputDecoration(
                                  hintText: "Search...",
                                  border: InputBorder.none,
                                  hintStyle: AppTextStyles.body.copyWith(
                                    color: AppColors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    // filter dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Color(0xFF1E1E1E)
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButton<String>(
                        value: selectedFilter,
                        underline: SizedBox(),
                        isExpanded: true,
                        onChanged: (v) => setState(() => selectedFilter = v!),
                        items: filters.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: AppTextStyles.body.copyWith(
                                color:
                                    (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF1E1E1E)
                                          : Colors.white)
                                    : AppColors.darkOlive),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 18),

                    // two btns
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/salary_estimator');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.getAccentColor(
                                context,
                              ),
                              foregroundColor:
                                  (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Color(0xFF1E1E1E)
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.white)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text("Salary Estimation"),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/cv_analyzer');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.getSecondaryColor(
                                context,
                              ),
                              foregroundColor:
                                  (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Color(0xFF1E1E1E)
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.white)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text("CV Analyzer"),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // job cards
                    Column(
                      children: filteredJobs.map((job) {
                        final isSaved = savedJobs.contains(job.id);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color:
                                (Theme.of(context).brightness == Brightness.dark
                                ? Color(0xFF1E1E1E)
                                : (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.white)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppColors.grey.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      job.logo,
                                      size: 28,
                                      color: AppColors.getMainColor(context),
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job.title,
                                          style: AppTextStyles.body.copyWith(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? (Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? const Color(0xFF1E1E1E)
                                                      : Colors.white)
                                                : AppColors.darkOlive),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          job.company,
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => toggleSaveJob(job.id),
                                    icon: Icon(
                                      isSaved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: isSaved
                                          ? AppColors.getSecondaryColor(context)
                                          : AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 14),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 15,
                                    color: AppColors.grey,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    job.location,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "â€¢",
                                    style: TextStyle(color: AppColors.grey),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    job.salary,
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
