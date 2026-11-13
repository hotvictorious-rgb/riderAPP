// lib/core/constants/api_endpoints.dart
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
        return '${Uri.base.scheme}://$host:8000/api/v1';
      }
      return 'http://127.0.0.1:8000/api/v1';
    }
    // Native Mobile (Android APK / AAB & iOS) targets official production backend
    return 'https://shop.victoriousmarket.com.ng/api/v1';
  }

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/me';

  // Rider Terminal Endpoints
  static const String riderDashboard = '/rider/dashboard';
  static const String riderToggleDuty = '/rider/toggle-duty';
  static const String riderActiveOrders = '/rider/orders/active';
  static const String riderHistory = '/rider/orders/history';
  static const String riderMarkArrived = '/rider/orders/mark-arrived';
  static const String riderVerifyPickupOtp = '/rider/orders/verify-pickup-otp';
  static const String riderVerifyDeliveryOtp = '/rider/orders/verify-delivery-otp';
  static const String riderDoorstepHandover = '/rider/orders/doorstep-handover';
  static const String riderVerifyVendorReturnOtp = '/rider/orders/verify-vendor-return-otp';
  static const String riderActiveReturns = '/rider/returns/active';
  static const String riderDeliveryAttemptFailed = '/rider/orders/delivery-attempt-failed';

  // Notification & Device Token Endpoints
  static const String registerDeviceToken = '/rider/device-token';
  static const String revokeDeviceToken = '/notifications/device-token';
  static const String inAppNotifications = '/notifications/in-app';
  static const String markNotificationRead = '/notifications/mark-read';
}
