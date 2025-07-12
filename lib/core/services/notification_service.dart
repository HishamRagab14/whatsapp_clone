// ignore_for_file: avoid_print

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'background_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// تهيئة الإشعارات
  Future<void> initialize() async {
    try {
      // طلب إذن الإشعارات
      await _requestPermission();
      
      // تهيئة الإشعارات المحلية
      await _initializeLocalNotifications();
      
      // إعداد معالجات الإشعارات
      await _setupNotificationHandlers();
      
      // الحصول على FCM Token
      await _getFCMToken();
      
      print('✅ Notifications initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  /// طلب إذن الإشعارات
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  /// تهيئة الإشعارات المحلية
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// إعداد معالجات الإشعارات
  Future<void> _setupNotificationHandlers() async {
    // إشعارات في الخلفية
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    
    // إشعارات في المقدمة
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // عند فتح الإشعار
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpened);
  }

  /// الحصول على FCM Token
  Future<String?> _getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// معالج الإشعارات في المقدمة
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      
      // إظهار إشعار محلي
      _showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'New Message',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// معالج فتح الإشعار
  void _handleNotificationOpened(RemoteMessage message) {
    print('Notification opened: ${message.data}');
    
    // التنقل إلى الشاشة المناسبة
    _navigateToScreen(message.data);
  }

  /// معالج النقر على الإشعار المحلي
  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    
    // التنقل إلى الشاشة المناسبة
    if (response.payload != null) {
      // تحويل الـ payload إلى Map
      // _navigateToScreen(parsePayload(response.payload!));
    }
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

    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  /// إظهار إشعار محلي (للاستخدام العام)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _showLocalNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );
  }

  /// التنقل إلى الشاشة المناسبة
  void _navigateToScreen(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'message':
        // التنقل إلى شاشة المحادثة
        Get.toNamed('/chat-detail', arguments: {'chatId': id});
        break;
      case 'status':
        // التنقل إلى شاشة الـ Status
        Get.toNamed('/status-view', arguments: {'statusId': id});
        break;
      case 'call':
        // التنقل إلى شاشة المكالمة
        Get.toNamed('/call', arguments: {'callId': id});
        break;
      default:
        // التنقل إلى الشاشة الرئيسية
        Get.toNamed('/home');
    }
  }

  /// الاشتراك في Topic معين
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// إلغاء الاشتراك من Topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  /// إرسال إشعار محلي للاختبار
  Future<void> showTestNotification() async {
    await showNotification(
      id: 1,
      title: 'Test Notification',
      body: 'This is a test notification from WhatsApp Clone!',
      payload: 'test',
    );
  }
} 