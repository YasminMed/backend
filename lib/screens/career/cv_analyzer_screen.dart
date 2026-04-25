import 'package:flutter/material.dart';
import 'package:skillora/constants/app_colors.dart';
import 'package:skillora/constants/app_text_styles.dart';

class CVAnalyzerWidget extends StatefulWidget {
  const CVAnalyzerWidget({super.key});

  @override
  State<CVAnalyzerWidget> createState() => _CVAnalyzerWidgetState();
}

class _CVAnalyzerWidgetState extends State<CVAnalyzerWidget> {
  bool isUploaded = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.getBackgroundColor(context),
        child: Column(
          children: [
            // Custom AppBar
            Container(
              height: 60,
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
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'CV Analyzer',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 20,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 430),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: isUploaded ? _buildAnalysisView() : _buildUploadView(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // upload view
  Widget _buildUploadView() {
    return Column(
      children: [
        SizedBox(height: 32),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.softGreen.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            Icons.insert_drive_file,
            size: 60,
            color: AppColors.getMainColor(context),
          ),
        ),
        SizedBox(height: 24),
        Text('Analyze Your CV', style: AppTextStyles.h2),
        SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              isUploaded = true;
            });
          },
          icon: Icon(Icons.upload_file),
          label: Text('Upload CV', style: AppTextStyles.button),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.getMainColor(context),
            foregroundColor: AppColors.getTextColor(context),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Supported formats: PDF, DOC, DOCX',
          style: AppTextStyles.tiny.copyWith(color: AppColors.grey),
        ),
        SizedBox(height: 32),
        _buildInfoCard(
          context,
          'ATS Compatibility Check',
          'Ensure your CV passes applicant tracking systems',
          AppColors.lime,
          Icons.check_circle_outline,
        ),
        SizedBox(height: 8),
        _buildInfoCard(
          context,
          'Skills Analysis',
          'Identify and highlight your key skills',
          AppColors.getAccentColor(context),
          Icons.psychology_outlined,
        ),
        SizedBox(height: 8),
        _buildInfoCard(
          context,
          'Improvement Tips',
          'Get personalized recommendations',
          AppColors.softGreen,
          Icons.lightbulb_outline,
        ),
        SizedBox(height: 24),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CareerDetailsWidget()),
            );
          },
          child: Text(
            'View Career Details â†’',
            style: AppTextStyles.label.copyWith(
              color: AppColors.getMainColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white)
                        : Colors.black)
                    .withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.tiny.copyWith(color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // analysis view
  Widget _buildAnalysisView() {
    final strengths = [
      'Strong technical skills section',
      'Clear work experience timeline',
      'Quantified achievements',
      'Professional summary included',
    ];
    final improvements = [
      'Add more action verbs',
      'Include relevant certifications',
      'Optimize for ATS keywords',
      'Add links to portfolio/projects',
    ];
    final skills = [
      'JavaScript',
      'React',
      'Python',
      'SQL',
      'Project Management',
      'Team Leadership',
      'Problem Solving',
      'Communication',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: 0.78,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.getMainColor(context),
                  ),
                ),
              ),
              Column(
                children: [
                  Text('78', style: AppTextStyles.h1.copyWith(fontSize: 48)),
                  Text(
                    'Good CV!',
                    style: AppTextStyles.body.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        Text('Strengths', style: AppTextStyles.h2.copyWith(fontSize: 20)),
        const SizedBox(height: 8),
        _buildListCard(
          context,
          strengths,
          Icons.check_circle,
          AppColors.getMainColor(context),
        ),
        const SizedBox(height: 8),
        Text(
          'Areas to Improve',
          style: AppTextStyles.h2.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 8),
        _buildListCard(
          context,
          improvements,
          Icons.error_outline,
          AppColors.getAccentColor(context),
        ),
        SizedBox(height: 8),
        Text('Detected Skills', style: AppTextStyles.h2.copyWith(fontSize: 20)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(skill, style: AppTextStyles.small),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        Text('Recommendations', style: AppTextStyles.h2.copyWith(fontSize: 20)),
        const SizedBox(height: 8),
        _buildRecommendationCard(
          context,
          'Add Portfolio Link',
          'Include links to your GitHub, portfolio, or professional website',
          AppColors.lime,
          Icons.lightbulb_outline,
        ),
        _buildRecommendationCard(
          context,
          'Quantify More Results',
          'Add more numbers and metrics to showcase your achievements',
          AppColors.getAccentColor(context),
          Icons.trending_up,
        ),
        _buildRecommendationCard(
          context,
          'Update Skills Section',
          'Add emerging technologies and tools relevant to your field',
          AppColors.softGreen,
          Icons.emoji_events_outlined,
        ),
      ],
    );
  }

  Widget _buildListCard(
    BuildContext context,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white)
                        : Colors.black)
                    .withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text(item, style: AppTextStyles.small)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white)
                        : Colors.black)
                    .withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.tiny.copyWith(color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// career details widget
class CareerDetailsWidget extends StatelessWidget {
  const CareerDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom AppBar
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: AppColors.softGreen,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Career Details',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 20,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(maxWidth: 430),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 24),
                  // Hero Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.getMainColor(context),
                          AppColors.lime,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color:
                                    (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Color(0xFF1E1E1E)
                                    : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF1E1E1E)
                                          : Colors.white)),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.engineering,
                                color:
                                    (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF1E1E1E)
                                          : Colors.white)
                                    : AppColors.darkOlive),
                                size: 32,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Software Engineer',
                                    style: AppTextStyles.h2.copyWith(
                                      fontSize: 22,
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
                                  SizedBox(height: 4),
                                  Text(
                                    'Technology & Development',
                                    style: AppTextStyles.small.copyWith(
                                      color:
                                          (Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? (Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                        ? const Color(
                                                            0xFF1E1E1E,
                                                          )
                                                        : Colors.white)
                                                  : AppColors.darkOlive)
                                              .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            _buildInfoChip(
                              context,
                              Icons.attach_money,
                              '\$85K - \$120K',
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              context,
                              Icons.trending_up,
                              'High Demand',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  // Overview
                  Text(
                    'Overview',
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Color(0xFF1E1E1E)
                          : (Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white)),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                      ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? const Color(0xFF1E1E1E)
                                            : Colors.white)
                                      : Colors.black)
                                  .withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Software engineers design, develop, and maintain software applications. They work with programming languages, frameworks, and tools to create solutions that solve real-world problems.',
                      style: AppTextStyles.body,
                    ),
                  ),
                  SizedBox(height: 24),
                  // Key Responsibilities
                  Text(
                    'Key Responsibilities',
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  _buildResponsibilityCard(
                    context,
                    'Write clean, efficient code',
                    'Develop high-quality software using best practices',
                    Icons.code,
                    AppColors.getMainColor(context),
                  ),
                  _buildResponsibilityCard(
                    context,
                    'Collaborate with teams',
                    'Work with designers, product managers, and other engineers',
                    Icons.people,
                    AppColors.lime,
                  ),
                  _buildResponsibilityCard(
                    context,
                    'Debug and troubleshoot',
                    'Identify and fix issues in existing software systems',
                    Icons.bug_report,
                    AppColors.getAccentColor(context),
                  ),
                  SizedBox(height: 24),
                  // Skills
                  Text(
                    'Required Skills',
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildSkillChip(
                        context,
                        'JavaScript',
                        AppColors.getMainColor(context),
                      ),
                      _buildSkillChip(context, 'React', AppColors.lime),
                      _buildSkillChip(
                        context,
                        'Python',
                        AppColors.getAccentColor(context),
                      ),
                      _buildSkillChip(
                        context,
                        'Git',
                        AppColors.getMainColor(context),
                      ),
                      _buildSkillChip(
                        context,
                        'Problem Solving',
                        AppColors.lime,
                      ),
                      _buildSkillChip(
                        context,
                        'Teamwork',
                        AppColors.getAccentColor(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.getSurfaceColor(context) == Colors.white
                ? AppColors.darkOlive
                : Colors.white,
          ),
          SizedBox(width: 4),
          Text(label, style: AppTextStyles.small),
        ],
      ),
    );
  }

  Widget _buildResponsibilityCard(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                (Theme.of(context).brightness == Brightness.dark
                        ? (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white)
                        : Colors.black)
                    .withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                SizedBox(height: 4),
                Text(
                  desc,
                  style: AppTextStyles.tiny.copyWith(color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(BuildContext context, String skill, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        skill,
        style: AppTextStyles.small.copyWith(
          color: AppColors.getSurfaceColor(context) == Colors.white
              ? AppColors.darkOlive
              : Colors.white,
        ),
      ),
    );
  }
}
