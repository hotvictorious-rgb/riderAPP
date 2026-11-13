import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint("🏍️ [Rider FCM Background]: ${message.messageId} - ${message.notification?.title}");
  }
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'victorious_rider_dispatch_alerts',
    'Victorious Rider Dispatch Alerts',
    description: 'Instant dispatch alerts for assigned orders, merchant ready pickups, and corridor route updates.',
    importance: Importance.max,
    playSound: true,
  );

  bool _isInitialized = false;
  String? _cachedToken;

  String? get fcmToken => _cachedToken;

  Future<void> initialize(ApiClient apiClient) async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      if (kDebugMode) {
        debugPrint('🏍️ [Rider FCM Auth Status]: ${settings.authorizationStatus}');
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (kDebugMode) {
            debugPrint('🏍️ [Rider Notification Tapped]: ${response.payload}');
          }
        },
      );

      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_channel);
      }

      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('🏍️ [Rider Opened From Background]: ${message.data}');
        }
      });

      _cachedToken = await _fcm.getToken();
      if (_cachedToken != null) {
        if (kDebugMode) {
          debugPrint('📲 [Rider FCM Token]: $_cachedToken');
        }
        await _syncTokenWithBackend(apiClient, _cachedToken!);
      }

      _fcm.onTokenRefresh.listen((newToken) async {
        _cachedToken = newToken;
        await _syncTokenWithBackend(apiClient, newToken);
      });

      _isInitialized = true;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('⚠️ [Rider Push Init Error]: $e\n$stack');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title ?? 'Dispatch Alert',
        body: notification.body ?? 'New order ready for pickup.',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _syncTokenWithBackend(ApiClient apiClient, String token) async {
    try {
      await apiClient.post(
        '/api/v1/notifications/device-token',
        data: {
          'device_token': token,
          'fcm_token': token,
          'app_role': 'rider',
        },
      );
      if (kDebugMode) {
        debugPrint('✅ [Rider FCM Token Synced With Backend]');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [Rider FCM Sync Warning]: $e');
      }
    }
  }
}

