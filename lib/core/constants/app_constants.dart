// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'Victorious Rider';
  static const String appTagline = 'Sovereign Courier Dispatch Terminal';

  // Storage Keys
  static const String tokenKey = 'rider_auth_token';
  static const String userKey = 'rider_user_data';
  static const String profileKey = 'rider_profile_data';
  static const String isOnlineKey = 'rider_duty_is_online';
  static const String apiBaseUrlKey = 'rider_api_base_url_custom';

  // Handover Rules
  static const int otpLength = 6;
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Strict Role Invariant
  static const String requiredUserType = 'rider';
  static const String terminalType = 'rider';
}
