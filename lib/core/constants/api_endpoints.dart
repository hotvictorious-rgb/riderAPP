// lib/core/constants/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = 'http://127.0.0.1:8080/api/v1';

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
}
