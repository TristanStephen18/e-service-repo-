import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHanlder(RemoteMessage message) async {
  await NotifService.instance.setupFlutterNotif();
  await NotifService.instance.showNotification(message);
}

class NotifService {
  NotifService._();

  static final NotifService instance = NotifService._();

  final _messaging = FirebaseMessaging.instance;
  final _localnotifications = FlutterLocalNotificationsPlugin();
  bool _isNotifInitialized = false;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHanlder);
    await _requestPermission();
    await _setupMessageHandlers();

    final token = await _messaging.getToken();
    print('FCM TOKEN: $token');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    );
    print("Permission: ${settings.authorizationStatus}");
  }

  Future<void> setupFlutterNotif() async {
    if (_isNotifInitialized) {
      return;
    }

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localnotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const initializationSettingAndroid = AndroidInitializationSettings('notif');

    final initializationSettings = InitializationSettings(
      android: initializationSettingAndroid,
    );

    await _localnotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    _isNotifInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localnotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'notif',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });
    void _handleBackgroundMessage(RemoteMessage message) {
      if (message.data['type'] == 'chat') {}
    }

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }
}
