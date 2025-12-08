// fb_cloud_msg.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

// Background handler (required for FCM)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FBCloudMSG.showNotification(
    message.notification?.title ?? 'New Notification',
    message.notification?.body ?? '',
    imageUrl: message.notification?.android?.imageUrl,
  );
}

class FBCloudMSG {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize FCM & local notifications
  static Future<void> init() async {
    //-------------------------------------------------------------
    // 1️⃣ LOCAL NOTIFICATION INITIALIZATION (iOS + Android)
    //-------------------------------------------------------------
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle tap
      },
    );

    //-------------------------------------------------------------
    // 2️⃣ FCM PERMISSIONS (required on iOS)
    //-------------------------------------------------------------
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // iOS foreground notification behavior
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    }

    //-------------------------------------------------------------
    // 3️⃣ FOREGROUND MESSAGES (Android + iOS)
    //-------------------------------------------------------------
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? '',
        imageUrl: message.notification?.android?.imageUrl,
      );
    });

    //-------------------------------------------------------------
    // 4️⃣ BACKGROUND / TERMINATED
    //-------------------------------------------------------------
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    });

    //-------------------------------------------------------------
    // 5️⃣ Subscribe device to a topic
    //-------------------------------------------------------------
    await FirebaseMessaging.instance.subscribeToTopic('allUsers');
  }

  /// Show local notification
  static Future<void> showNotification(
    String title,
    String body, {
    String? imageUrl,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'all_orders_channel',
      'allUsers',
      channelDescription: 'Notifications for all users',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }
}
