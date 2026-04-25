import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_init;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('Notifications not supported on Web in this implementation');
      return;
    }

    // Initialize Timezone
    tz_init.initializeTimeZones();
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timezoneInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Initialize Local Notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    // FCM Handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    await requestPermission();
    
    // Get and save token
    await updateFCMTokenInFirestore();
  }

  Future<void> requestPermission() async {
    if (kIsWeb) return;
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> updateFCMTokenInFirestore() async {
    if (kIsWeb) return;
    try {
      String? token = await _fcm.getToken();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': token,
        });
        debugPrint('FCM Token updated in Firestore');
      }
    } catch (e) {
      debugPrint('Error updating FCM Token: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message received: ${message.notification?.title}');
    
    // Save to Firestore
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('notifications').add({
          'title': message.notification?.title ?? 'Skillora Update',
          'body': message.notification?.body ?? '',
          'timestamp': FieldValue.serverTimestamp(),
          'data': message.data,
        });
      }
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }

    // Show local notification for foreground messages
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'skillora_channel',
      'Skillora Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await FlutterLocalNotificationsPlugin().show(
      id: message.hashCode,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: details,
      payload: message.data.toString(),
    );
  }

  // Periodic Local Notifications (Every 4 hours)
  Future<void> schedulePeriodicNotifications(String role, bool enabled) async {
    if (kIsWeb) return;
    // Cancel existing ones first
    await _localNotifications.cancelAll();

    if (!enabled) return;

    List<String> messages = [];
    if (role == 'student') {
      messages = [
        "New goal should be achieved! Check your study plan.",
        "Keep working on your journey, success is near!",
        "It's been a while since you accessed your course. Ready to learn?",
        "Don't forget to track your daily study hours!",
      ];
    } else {
      // worker / career messages
      messages = [
        "Check new job opportunities matching your skills!",
        "Update your portfolio to stand out to recruiters.",
        "Career Roadmap update: New milestones available.",
        "Time to analyze your CV? Keep it professional!",
      ];
    }

    // Schedule 6 notifications for the next 24 hours (every 4 hours)
    for (int i = 1; i <= 6; i++) {
      final scheduledDate = tz.TZDateTime.now(tz.local).add(Duration(hours: 4 * i));
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'skillora_periodic',
        'Skillora Reminders',
        channelDescription: 'Periodic study and career reminders',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      await _localNotifications.zonedSchedule(
        id: i,
        title: 'Skillora Update',
        body: messages[i % messages.length],
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at this time?
      );
    }
    
    debugPrint('Scheduled $role notifications for next 24 hours');
  }
}

// Background handler must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}
