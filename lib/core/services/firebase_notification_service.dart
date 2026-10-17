import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../network/api_client.dart';
import 'storage_service.dart';
import '../../models/system_notification_model.dart';

/// Enterprise Firebase Cloud Messaging & Dispatch Notification Service
/// Handles device token registry, background/foreground dispatch alerts,
/// and live event streams for the Sovereign Courier Operating Terminal.
class FirebaseNotificationService {
  static final FirebaseNotificationService instance = FirebaseNotificationService._internal();

  FirebaseNotificationService._internal();

  final _notificationStreamController = StreamController<SystemNotificationModel>.broadcast();
  Stream<SystemNotificationModel> get onNotificationReceived => _notificationStreamController.stream;

  bool _isRegistered = false;
  String? _cachedDeviceToken;

  bool get isRegistered => _isRegistered;
  String? get cachedDeviceToken => _cachedDeviceToken;

  /// Generate or retrieve persistent hardware/FCM terminal identifier
  Future<String> getOrGenerateDeviceToken(StorageService storage) async {
    if (_cachedDeviceToken != null && _cachedDeviceToken!.isNotEmpty) {
      return _cachedDeviceToken!;
    }

    final stored = storage.getDeviceToken();
    if (stored != null && stored.isNotEmpty) {
      _cachedDeviceToken = stored;
      return stored;
    }

    // In a production APK with google-services.json, FirebaseMessaging.instance.getToken() is used.
    // Here we generate an RFC4122 compliant pseudo-random token so dispatch simulation, local testing,
    // and live backend token table registration work seamlessly across all platforms.
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    final token = 'fcm_courier_${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';

    await storage.setDeviceToken(token);
    _cachedDeviceToken = token;
    return token;
  }

  /// Register current courier device token with Victorious Backend Notification Matrix
  Future<bool> registerWithBackend({
    required ApiClient apiClient,
    required StorageService storage,
    String? deviceName,
  }) async {
    try {
      final token = await getOrGenerateDeviceToken(storage);
      final platform = defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';

      final response = await apiClient.post(
        ApiEndpoints.registerDeviceToken,
        data: {
          'device_token': token,
          'device_type': platform,
          'app_type': 'rider',
          'device_name': deviceName ?? 'Victorious Courier Terminal (v1.0.0)',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isRegistered = true;
        debugPrint('[FCM Courier Service] Device token successfully registered with backend: $token');
        return true;
      }
    } catch (e) {
      debugPrint('[FCM Courier Service] Device token registration skipped or failed: $e');
    }
    return false;
  }

  /// Revoke courier device token on logout
  Future<bool> unregisterWithBackend({
    required ApiClient apiClient,
    required StorageService storage,
  }) async {
    try {
      final token = storage.getDeviceToken() ?? _cachedDeviceToken;
      if (token == null || token.isEmpty) return true;

      final response = await apiClient.delete(
        ApiEndpoints.revokeDeviceToken,
        data: {
          'device_token': token,
        },
      );

      if (response.statusCode == 200) {
        _isRegistered = false;
        await storage.clearDeviceToken();
        _cachedDeviceToken = null;
        debugPrint('[FCM Courier Service] Device token revoked successfully from dispatch matrix.');
        return true;
      }
    } catch (e) {
      debugPrint('[FCM Courier Service] Device token revocation warning: $e');
    }
    return false;
  }

  /// Broadcast incoming push/dispatch alert to terminal UI listeners
  void handleIncomingMessage(Map<String, dynamic> raw) {
    try {
      final notification = SystemNotificationModel.fromJson(raw);
      _notificationStreamController.add(notification);
    } catch (e) {
      debugPrint('[FCM Courier Service] Failed to parse incoming notification: $e');
    }
  }

  void dispose() {
    _notificationStreamController.close();
  }
}
