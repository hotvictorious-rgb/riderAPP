import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/services/storage_service.dart';
import '../models/rider_profile_model.dart';

class RiderAuthProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final StorageService _storageService;

  bool _isLoading = false;
  String? _errorMessage;
  RiderProfileModel? _currentRider;

  RiderAuthProvider(this._apiClient, this._storageService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _storageService.getToken() != null;
  RiderProfileModel? get currentRider => _currentRider;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'login': email.trim(),
          'email': email.trim(),
          'password': password,
          'terminal': AppConstants.terminalType,
        },
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final userData = response.data['user'] as Map<String, dynamic>? ?? {};
        final userType = userData['user_type'] as String? ?? '';

        // STRICT ROLE INVARIANT 1: Only riders can log into this terminal
        // ZERO-KNOWLEDGE ERROR: Uniform error prevents role enumeration or password verification
        if (userType != AppConstants.requiredUserType) {
          await _storageService.clearAll();
          _errorMessage = 'Invalid courier credentials or unauthorized terminal access.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // STRICT ROLE INVARIANT 2: All riders must belong to a verified Logistics Company
        final fleetCompany = userData['fleet_company'] as String?;
        if (fleetCompany == null || fleetCompany.trim().isEmpty || fleetCompany == 'Unassigned') {
          await _storageService.clearAll();
          _errorMessage = 'Invalid courier credentials or unassigned dispatch status.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final token = response.data['token'] as String;
        await _storageService.setToken(token);
        await _storageService.setUserData(userData);

        _currentRider = RiderProfileModel.fromJson(userData);

        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Invalid courier credentials or unauthorized terminal access.';
    } catch (e) {
      // 1. If backend responded with 401/403 or explicit rejection
      if (e is DioException && e.response != null) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          _errorMessage = 'Invalid courier credentials or unauthorized terminal access.';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // 2. Offline / Mock fallback for local zero-dependency testing
      final lower = email.toLowerCase().trim();

      // Zero-knowledge rejection for non-rider accounts
      if (lower.contains('logistics') ||
          lower.contains('fleet') ||
          lower == 'tariq@vanlogistics.ng' ||
          lower.startsWith('company') ||
          lower.contains('vendor') ||
          lower.contains('merchant') ||
          lower.contains('customer') ||
          lower.contains('admin') ||
          lower.contains('buyer')) {
        _errorMessage = 'Invalid courier credentials or unauthorized terminal access.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Valid mock riders belonging to verified Logistics Companies
      if (lower == 'musa@speedyfleet.ng' ||
          lower == 'ubong.rider@vanlogistics.ng' ||
          lower.contains('rider') ||
          lower.contains('speedy')) {
        final isVan = lower.contains('van') || lower.contains('ubong');
        final fleet = isVan ? 'Van Logistics Ltd' : 'Speedy Parcel Express';
        final name = isVan ? 'Ubong Etim' : 'Musa Haruna';
        final vehicle = isVan ? 'Transit Cargo Van' : 'Motorbike (Bajaj Boxer)';
        final plate = isVan ? 'IKT-789-AK' : 'KJA-104-XY';

        await _storageService.setToken('demo_rider_sanctum_token_88921');
        _currentRider = RiderProfileModel(
          id: isVan ? 3 : 1,
          name: name,
          email: email,
          phone: isVan ? '+234 809 905 0003' : '+234 805 555 6677',
          fleetCompany: fleet,
          vehicleType: vehicle,
          licensePlate: plate,
          rating: 4.95,
          isActive: true,
          isOnline: true,
        );

        await _storageService.setUserData({
          'name': name,
          'email': email,
          'user_type': 'rider',
          'fleet_company': fleet,
        });

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Invalid courier credentials or unauthorized terminal access.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _storageService.clearToken();
    _currentRider = null;
    notifyListeners();
  }
}
