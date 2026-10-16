import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/services/storage_service.dart';
import '../models/rider_dashboard_model.dart';
import '../models/rider_profile_model.dart';

class RiderDashboardProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final StorageService _storageService;

  bool _isLoading = false;
  String? _errorMessage;
  RiderProfileModel? _profile;
  RiderDashboardModel? _dashboardMetrics;
  bool _isDutyOnline = true;

  RiderDashboardProvider(this._apiClient, this._storageService) {
    _isDutyOnline = _storageService.isDutyOnline();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RiderProfileModel? get profile => _profile;
  RiderDashboardModel? get dashboardMetrics => _dashboardMetrics;
  bool get isDutyOnline => _isDutyOnline;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.riderDashboard);
      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        if (data['rider'] != null) {
          _profile = RiderProfileModel.fromJson(data['rider']);
        }
        if (data['operational_telemetry'] != null) {
          _dashboardMetrics = RiderDashboardModel.fromJson(data['operational_telemetry']);
        } else {
          _dashboardMetrics = RiderDashboardModel(
            activeAssignmentsCount: 0,
            completedTripsCount: 0,
            shiftStatus: _profile?.isOnline == true ? 'ON DUTY' : 'OFF DUTY',
          );
        }
        _isDutyOnline = _profile?.isOnline ?? true;
        await _storageService.setDutyOnline(_isDutyOnline);
      }
    } catch (e) {
      _errorMessage = 'Unable to sync telemetry with dispatch server.';
      final cachedUser = _storageService.getUserData();
      if (cachedUser != null) {
        _profile = RiderProfileModel.fromJson(cachedUser);
      }
      _dashboardMetrics ??= RiderDashboardModel(
        activeAssignmentsCount: 0,
        completedTripsCount: 0,
        shiftStatus: _isDutyOnline ? 'ON DUTY' : 'OFF DUTY',
        assignedCorridor: '',
        onTimeRatePercent: 100.0,
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleDuty() async {
    final nextState = !_isDutyOnline;
    _isDutyOnline = nextState;
    await _storageService.setDutyOnline(nextState);
    if (_profile != null) {
      _profile = _profile!.copyWith(isOnline: nextState);
    }
    notifyListeners();

    try {
      await _apiClient.post(ApiEndpoints.riderToggleDuty);
      return true;
    } catch (_) {
      // Local state already updated
      return true;
    }
  }
}