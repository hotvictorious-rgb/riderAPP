// lib/core/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Token Management
  Future<bool> setToken(String token) async {
    return await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<bool> clearToken() async {
    return await _prefs.remove(AppConstants.tokenKey);
  }

  // Duty Status Management
  Future<bool> setDutyOnline(bool isOnline) async {
    return await _prefs.setBool(AppConstants.isOnlineKey, isOnline);
  }

  bool isDutyOnline() {
    return _prefs.getBool(AppConstants.isOnlineKey) ?? true;
  }

  // Dynamic API Base URL
  Future<bool> setApiBaseUrl(String url) async {
    return await _prefs.setString(AppConstants.apiBaseUrlKey, url);
  }

  String? getApiBaseUrl() {
    return _prefs.getString(AppConstants.apiBaseUrlKey);
  }

  // User Profile Caching
  Future<bool> setUserData(Map<String, dynamic> user) async {
    return await _prefs.setString(AppConstants.userKey, jsonEncode(user));
  }

  Map<String, dynamic>? getUserData() {
    final raw = _prefs.getString(AppConstants.userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Device Push Notification Token Caching
  Future<bool> setDeviceToken(String token) async {
    return await _prefs.setString('courier_fcm_device_token', token);
  }

  String? getDeviceToken() {
    return _prefs.getString('courier_fcm_device_token');
  }

  Future<bool> clearDeviceToken() async {
    return await _prefs.remove('courier_fcm_device_token');
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
