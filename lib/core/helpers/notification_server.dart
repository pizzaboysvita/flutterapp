// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 1️⃣ Initialize notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // your app icon

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification clicked: ${details.payload}");
      },
    );
  }

  // 2️⃣ Show order success notification
  static Future<void> showOrderNotification({
    String title = 'Order Placed Successfully!',
    String body = 'Your order has been confirmed 🍕',
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'order_channel', // channel id
      'Order Notifications', // channel name
      channelDescription: 'Notifications for orders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'), // pizza logo
      styleInformation: DefaultStyleInformation(true, true),
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // notification id
      title,
      body,
      platformDetails,
      payload: 'order_success',
    );
  }
}
