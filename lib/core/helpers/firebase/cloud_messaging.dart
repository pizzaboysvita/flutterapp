// fb_cloud_msg.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 1️⃣ Background handler (must be a top-level function)
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
    // 1️⃣ Local notifications initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap

        // Navigate to screen if needed
      },
    );

    // 2️⃣ Request permissions (iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3️⃣ Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(
        message.notification?.title ?? 'New Notification',
        message.notification?.body ?? '',
        imageUrl: message.notification?.android?.imageUrl,
      );
    });

    // 4️⃣ Background / terminated messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate to screen if needed
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 5️⃣ Subscribe all devices to a topic
    await FirebaseMessaging.instance.subscribeToTopic('allUsers');
  }

  /// Show local notification
  static Future<void> showNotification(
    String title,
    String body, {
    String? imageUrl,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'all_orders_channel', // channel ID
      'allUsers', // Topic name
      channelDescription: 'Notifications for all users',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: imageUrl != null
          ? BigPictureStyleInformation(
              FilePathAndroidBitmap(imageUrl),
              contentTitle: title,
              summaryText: body,
            )
          : null,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );
  }
}
