import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:skillora/models/course_model.dart';
import 'package:skillora/models/user_model.dart';
import 'package:skillora/providers/auth_provider.dart';

class CourseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Course> _courses = [];
  bool _isLoading = false;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;

//filter courses dynamicly 
  List<Course> get takenCourses =>
      _courses.where((c) => c.isRegistered).toList();

//seperation login
  List<Course> get availableCourses =>
      _courses.where((c) => !c.isRegistered).toList();

  UserModel? _currentUser;

  // New reactive method for ProxyProvider
  void updateUser(UserModel? user) {
    if (user != _currentUser) {
      _currentUser = user;
      if (_courses.isNotEmpty && _currentUser != null) {
        updateRegistrationState(
          _currentUser!.registeredCourseIds,
          _currentUser!.courseProgress,
        );
      }
    }
  }

  Future<void> fetchCourses([
    List<String>? registeredIds,
    Map<String, dynamic>? userProgress,
  ]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('courses').get();
      _courses = snapshot.docs
          .map((doc) => Course.fromFirestore(doc.data(), doc.id))
          .toList();

      if (_courses.isEmpty) {
        await seedInitialCourses();
      }

      // Automatically use _currentUser data if arguments are omitted
      final targetIds = registeredIds ?? _currentUser?.registeredCourseIds;
      final targetProgress = userProgress ?? _currentUser?.courseProgress;

      if (targetIds != null) {
        updateRegistrationState(targetIds, targetProgress);
      }
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateRegistrationState(
    List<String> registeredIds, [
    Map<String, dynamic>? userProgress,
  ]) {
    for (int i = 0; i < _courses.length; i++) {
      final courseId = _courses[i].id;
      final isRegistered = registeredIds.contains(courseId);
      
      // Get per-user progress data if it exists
      int progress = 0;
      double hours = 0.0;
      List<bool> completedWeeks = List.filled(_courses[i].totalWeeks, false);

      if (userProgress != null && userProgress.containsKey(courseId)) {
        final data = userProgress[courseId] as Map<String, dynamic>;
        progress = data['progress'] ?? 0;
        hours = (data['hours'] ?? 0.0).toDouble();
        if (data['completedWeeks'] != null) {
          completedWeeks = List<bool>.from(data['completedWeeks']);
        }
      }

      _courses[i] = Course(
        id: _courses[i].id,
        title: _courses[i].title,
        difficulty: _courses[i].difficulty,
        duration: _courses[i].duration,
        iconName: _courses[i].iconName,
        progress: progress,
        hours: hours,
        isRegistered: isRegistered,
        totalWeeks: _courses[i].totalWeeks,
        completedWeeks: completedWeeks,
        weekContents: _courses[i].weekContents,
      );
    }
    notifyListeners();
  }

  Future<void> registerCourse(String courseId, {int totalWeeks = 1}) async {
    int index = _courses.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      Course c = _courses[index];
      _courses[index] = Course(
        id: c.id,
        title: c.title,
        difficulty: c.difficulty,
        duration: c.duration,
        iconName: c.iconName,
        progress: 0,
        hours: 0.0,
        isRegistered: true,
        totalWeeks: c.totalWeeks,
        completedWeeks: List.filled(c.totalWeeks, false),
        weekContents: c.weekContents,
      );
      notifyListeners();
    }
  }

  Future<void> unregisterCourse(String courseId) async {
    int index = _courses.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      Course c = _courses[index];
      _courses[index] = Course(
        id: c.id,
        title: c.title,
        difficulty: c.difficulty,
        duration: c.duration,
        iconName: c.iconName,
        progress: 0,
        hours: 0.0,
        isRegistered: false,
        totalWeeks: c.totalWeeks,
        completedWeeks: List.filled(c.totalWeeks, false),
        weekContents: c.weekContents,
      );
      notifyListeners();
    }
  }

  Future<void> updateCourseProgress(
    String courseId,
    int weekIndex,
    bool isCompleted,
    AuthProvider authProvider,
  ) async {
    int index = _courses.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      Course c = _courses[index];
      List<bool> newCompletedWeeks = List.from(c.completedWeeks);
      if (weekIndex >= 0 && weekIndex < newCompletedWeeks.length) {
        newCompletedWeeks[weekIndex] = isCompleted;

        int completedCount = newCompletedWeeks.where((w) => w).length;
        int newProgress = ((completedCount / c.totalWeeks) * 100).toInt();

        // Update local state
        _courses[index] = Course(
          id: c.id,
          title: c.title,
          difficulty: c.difficulty,
          duration: c.duration,
          iconName: c.iconName,
          progress: newProgress,
          hours: c.hours,
          isRegistered: c.isRegistered,
          totalWeeks: c.totalWeeks,
          completedWeeks: newCompletedWeeks,
          weekContents: c.weekContents,
        );

        notifyListeners();

        // Update USER'S document, NOT the global courses collection
        try {
          await authProvider.updateUserCourseData(courseId, {
            'progress': newProgress,
            'completedWeeks': newCompletedWeeks,
          });
        } catch (e) {
          debugPrint("Error updating course progress in user doc: $e");
        }
      }
    }
  }

  Future<void> updateCourseHours(
    String courseId,
    double additionalHours,
    AuthProvider authProvider,
  ) async {
    int index = _courses.indexWhere((c) => c.id == courseId);
    if (index != -1) {
      Course c = _courses[index];
      double newHours = c.hours + additionalHours;

      _courses[index] = Course(
        id: c.id,
        title: c.title,
        difficulty: c.difficulty,
        duration: c.duration,
        iconName: c.iconName,
        progress: c.progress,
        hours: newHours,
        isRegistered: c.isRegistered,
        totalWeeks: c.totalWeeks,
        completedWeeks: c.completedWeeks,
        weekContents: c.weekContents,
      );

      notifyListeners();

      // Update USER'S document, NOT the global courses collection
      try {
        await authProvider.updateUserCourseData(courseId, {
          'hours': newHours,
        });
      } catch (e) {
        debugPrint("Error updating course hours in user doc: $e");
      }
    }
  }

  // Helper to seed initial data if needed
  Future<void> seedInitialCourses() async {
    final initialCourses = [
      {
        'title': 'Web Development Fundamental',
        'difficulty': 'Medium',
        'duration': '8 weeks',
        'iconName': 'code',
        'isRegistered': false,
        'hours': 0.0,
        'progress': 0,
        'totalWeeks': 8,
        'completedWeeks': List.filled(8, false),
        'weekContents': _generateWeekContents('Web Development', 8),
      },
      {
        'title': 'UI/UX Design',
        'difficulty': 'Easy',
        'duration': '6 weeks',
        'iconName': 'palette',
        'isRegistered': false,
        'hours': 0.0,
        'progress': 0,
        'totalWeeks': 6,
        'completedWeeks': List.filled(6, false),
        'weekContents': _generateWeekContents('UI/UX Design', 6),
      },
      {
        'title': 'DS & Algorithms',
        'difficulty': 'Hard',
        'duration': '10 weeks',
        'iconName': 'psychology',
        'isRegistered': false,
        'hours': 0.0,
        'progress': 0,
        'totalWeeks': 10,
        'completedWeeks': List.filled(10, false),
        'weekContents': _generateWeekContents('DS & Algorithms', 10),
      },
      {
        'title': 'ML Basics',
        'difficulty': 'Medium',
        'duration': '7 weeks',
        'iconName': 'memory',
        'isRegistered': false,
        'hours': 0.0,
        'progress': 0,
        'totalWeeks': 7,
        'completedWeeks': List.filled(7, false),
        'weekContents': _generateWeekContents('ML Basics', 7),
      },
      {
        'title': 'Intro to Cybersecurity',
        'difficulty': 'Hard',
        'duration': '5 weeks',
        'iconName': 'security',
        'isRegistered': false,
        'hours': 0.0,
        'progress': 0,
        'totalWeeks': 5,
        'completedWeeks': List.filled(5, false),
        'weekContents': _generateWeekContents('Intro to Cybersecurity', 5),
      },
      {
        'title': 'Graphic Design Starter',
        'difficulty': 'Easy',
        'duration': '4 weeks',
        'iconName': 'brush',
        'isRegistered': false,
        'hours': 0.0,
        'progress': 0,
        'totalWeeks': 4,
        'completedWeeks': List.filled(4, false),
        'weekContents': _generateWeekContents('Graphic Design Starter', 4),
      },
    ];

    for (var course in initialCourses) {
      await _firestore.collection('courses').add(course);
    }
    await fetchCourses();
  }

  List<String> _generateWeekContents(String courseTitle, int weeks) {
    return List.generate(weeks, (index) {
      final weekNum = index + 1;
      String content = "Welcome to Week $weekNum of the $courseTitle course!\n\n";
      
      if (courseTitle.contains('Web Development')) {
        content += _getWebContent(weekNum);
      } else if (courseTitle.contains('UI/UX')) {
        content += _getUIUXContent(weekNum);
      } else if (courseTitle.contains('DS & Algorithms')) {
        content += _getAlgoContent(weekNum);
      } else if (courseTitle.contains('ML Basics')) {
        content += _getMLContent(weekNum);
      } else if (courseTitle.contains('Cybersecurity')) {
        content += _getCyberContent(weekNum);
      } else if (courseTitle.contains('Graphic Design')) {
        content += _getGraphicContent(weekNum);
      } else {
        content += _getDefaultContent(courseTitle, weekNum);
      }
      
      content += "\n\nMake sure to read through all the material provided this week. Understanding these concepts is crucial for your professional journey in $courseTitle. Once you finish reading, your progress for this week will be recorded automatically.";
      return content;
    });
  }

  String _getWebContent(int week) {
    switch (week) {
      case 1: return "This week, we introduce the World Wide Web, HTTP protocols, and basic HTML structure. You'll learn how the browser renders pages and how to create your first static website using headings, paragraphs, and lists.";
      case 2: return "Dive into CSS styling! Learn about selectors, the box model, colors, and fonts. We'll explore how to transform simple HTML into visually appealing interfaces using margin, padding, and borders.";
      case 3: return "Layout techniques are essential. This week covers Flexbox and CSS Grid. You'll build responsive components that adapt to different screen sizes, ensuring a seamless user experience across devices.";
      case 4: return "Introduction to JavaScript. Learn about variables, data types, and basic operators. We'll start making our websites interactive with simple event listeners and console debugging.";
      case 5: return "Advancing in JavaScript: Functions, scope, and arrays. Understand how to organize your code and manipulate lists of data efficiently.";
      case 6: return "The Document Object Model (DOM). Learn how JavaScript interacts with HTML elements. You'll build a dynamic 'To-Do' list that allows users to add and remove items in real-time.";
      case 7: return "Asynchronous programming and APIs. Explore fetch, promises, and JSON. You'll learn how to pull real-time data from external sources and display it on your site.";
      case 8: return "Deployment and best practices. We'll cover version control with Git, SEO basics, and how to host your project online using services like Netlify or Vercel.";
      default: return "Final review and advanced topics. Reflect on everything you've learned and start planning your final portfolio project.";
    }
  }

  String _getUIUXContent(int week) {
    switch (week) {
      case 1: return "Foundations of Design. Understand the difference between UI and UX. We'll explore design thinking, user-centric approaches, and the importance of empathy in the design process.";
      case 2: return "User Research and Personas. Learn how to conduct interviews and create user personas that guide your design decisions throughout the project.";
      case 3: return "Information Architecture and Wireframing. Create sitemaps and low-fidelity prototypes. You'll learn how to map out user journeys and structure content logically.";
      case 4: return "Visual Design Principles. Color theory, typography, and hierarchy. Understand how to create balanced, accessible, and aesthetically pleasing interfaces.";
      case 5: return "High-Fidelity Prototyping. Transition from wireframes to polished mockups in Tools like Figma. Learn about components, variants, and interactive prototyping.";
      case 6: return "Usability Testing and Iteration. Conduct tests with real users to identify pain points. Learn how to gather feedback and refine your designs based on actual user behavior.";
      default: return "Portfolio Building. Tips on how to present your UI/UX case studies and land your first design role.";
    }
  }

  String _getMLContent(int week) {
    switch (week) {
      case 1: return "Introduction to AI and Machine Learning. Understand the difference between artificial intelligence, machine learning, and deep learning. We'll explore supervises, unsupervised, and reinforcement learning paradigms.";
      case 2: return "Data Preprocessing and Exploration. Learn how to clean data, handle missing values, and scale features. Understanding your data through visualization is the first step in building a successful model.";
      case 3: return "Linear Regression. Dive into the simplest yet most powerful predictive algorithm. Learn about cost functions, gradient descent, and how to evaluate regression models using R-squared.";
      case 4: return "Classification with Logistic Regression and Decision Trees. Learn how to categorize data. We'll cover binary classification, decision boundaries, and how trees split data to make decisions.";
      case 5: return "Model Evaluation and Overfitting. Understand bias-variance tradeoff. Learn about cross-validation, precision, recall, and F1-score to ensure your model generalizes well to new data.";
      case 6: return "Introduction to Neural Networks. Explore the basics of perceptrons and how layers of neurons can learn complex patterns. We'll discuss activation functions and the backpropagation algorithm.";
      case 7: return "Real-world Applications and Ethics. See how ML is used in recommendation systems, image recognition, and natural language processing. Discuss the importance of fairness and transparency in AI.";
      default: return "Advanced ML Topics. A look into clustering, dimensionality reduction, and the future of transformer models.";
    }
  }

  String _getCyberContent(int week) {
    switch (week) {
      case 1: return "Cybersecurity Essentials. Learn about the CIA triad (Confidentiality, Integrity, Availability), common threats like phishing and malware, and the mindset of a security professional.";
      case 2: return "Network Security. Understand how data moves across the internet. Learn about IP addresses, ports, firewalls, and how to secure wireless networks against unauthorized access.";
      case 3: return "Cryptography Basics. Explore symmetric and asymmetric encryption. Learn how HTTPS works, the role of digital certificates, and why hashing is vital for storing passwords safely.";
      case 4: return "Web Security and OWASP Top 10. Dive into common web vulnerabilities like SQL injection and Cross-Site Scripting (XSS). Learn how to identify and mitigate these risks in your applications.";
      case 5: return "Incident Response and Career Paths. What happens when a breach occurs? Learn the steps of incident handling and explore various roles in the industry, from SOC analyst to pentester.";
      default: return "Advanced Defense Strategies. Focus on zero-trust architecture and automated threat detection.";
    }
  }

  String _getGraphicContent(int week) {
    switch (week) {
      case 1: return "Elements of Graphic Design. Lines, shapes, color, and texture. Learn how these basic building blocks work together to convey meaning and emotion in visual communication.";
      case 2: return "Typography and Layout. The art of arranging type. Understand font families, kerning, leading, and how to create balanced layouts that guide the viewer's eye.";
      case 3: return "Color Theory and Branding. Explore the psychology of color. Learn how to create color palettes that align with a brand's identity and resonate with the target audience.";
      case 4: return "Logo Design and Digital Publishing. Build your first brand mark. We'll discuss simplicity, memorability, and how to prepare files for both web and print production.";
      default: return "Design Critique and Portfolio. Learn how to give and receive constructive feedback to polish your work for a professional portfolio.";
    }
  }

  String _getAlgoContent(int week) {
    switch (week) {
      case 1: return "Complexity Analysis. Big O notation, time and space complexity. Understand how to evaluate the efficiency of your code before you even write it.";
      case 2: return "Linear Data Structures. Arrays, linked lists, stacks, and queues. Learn when and why to use each one based on operation costs.";
      case 3: return "Recursion and Basic Searching. Binary search, recursive patterns, and the divide-and-conquer strategy.";
      case 4: return "Sorting Algorithms. Bubble sort, insertion sort, quicksort, and mergesort. Understand the trade-offs between different sorting techniques.";
      case 5: return "Trees and Binary Search Trees. Introduction to non-linear structures. Learn about traversal methods (In-order, Pre-order, Post-order) and balancing.";
      case 6: return "Hashing and Hash Tables. Collision resolution strategies and constant-time lookups. Learn the magic behind efficient key-value pairs.";
      case 7: return "Graphs and Traversals. Breadth-First Search (BFS) and Depth-First Search (DFS). Discover how to model relationships and find paths.";
      case 8: return "Greedy Algorithms and Dynamic Programming. Solving complex problems by breaking them into overlapping subproblems or making locally optimal choices.";
      case 9: return "Advanced Graph Algorithms. Dijkstra's, Prim's, and Kruskal's for finding shortest paths and minimum spanning trees.";
      case 10: return "Heap and Priority Queues. Efficiently finding minimums or maximums. Final review of all data structures studied throughout the course.";
      default: return "Interview Prep. Focus on common coding challenges and patterns found in technical interviews at top tech companies.";
    }
  }

  String _getDefaultContent(String topic, int week) {
    return "This week we explore Chapter $week of $topic. "
           "We will dive into the core mechanisms that make this field so dynamic and impactful. "
           "Expect to cover fundamental theories and their practical implementations in the industry. "
           "By completing this week, you'll have a stronger grasp of $topic and be better prepared for real-world applications.";
  }
}
