// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// معالج الإشعارات في الخلفية
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  
  // إظهار إشعار محلي
  await _showLocalNotification(
    id: message.hashCode,
    title: message.notification?.title ?? 'New Message',
    body: message.notification?.body ?? '',
    payload: message.data.toString(),
  );
}

/// إظهار إشعار محلي
Future<void> _showLocalNotification({
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'whatsapp_clone_channel',
    'WhatsApp Clone Notifications',
    channelDescription: 'Notifications for WhatsApp Clone app',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
  );
  
  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();
  
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  final FlutterLocalNotificationsPlugin localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  await localNotifications.show(
    id,
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
} 