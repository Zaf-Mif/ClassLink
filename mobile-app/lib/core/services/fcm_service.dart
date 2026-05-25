import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

class FcmService {
  final ApiClient _apiClient;
  final FlutterLocalNotificationsPlugin _localNotifications;

  FcmService(this._apiClient)
      : _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await messaging.getToken();
    if (token != null) {
      await _uploadToken(token);
    }

    messaging.onTokenRefresh.listen(_uploadToken);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapData);
  }

  Future<void> _uploadToken(String token) async {
    try {
      await _apiClient.dio.post('/users/fcm-token', data: {
        'fcmToken': token,
      });
    } catch (_) {}
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'ClassLink';
    final body = message.notification?.body ?? '';

    const androidDetails = AndroidNotificationDetails(
      'classlink_channel',
      'ClassLink Notifications',
      channelDescription: 'Notifications from ClassLink',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: message.messageId.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: message.data['referenceId'],
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      // Navigate to detail screen based on payload
    }
  }

  void _onNotificationTapData(RemoteMessage message) {
    // Deep link navigation on tap
  }
}
