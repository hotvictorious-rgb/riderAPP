import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/delivery_assignment_model.dart';

class RiderDeliveryProvider with ChangeNotifier {
  final ApiClient _apiClient;

  bool _isLoading = false;
  String? _errorMessage;
  List<DeliveryAssignmentModel> _activeDeliveries = [];
  List<DeliveryAssignmentModel> _history = [];
  DeliveryAssignmentModel? _selectedDelivery;

  RiderDeliveryProvider(this._apiClient);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DeliveryAssignmentModel> get activeDeliveries => _activeDeliveries;
  List<DeliveryAssignmentModel> get history => _history;
  DeliveryAssignmentModel? get selectedDelivery => _selectedDelivery;

  void selectDelivery(DeliveryAssignmentModel item) {
    _selectedDelivery = item;
    notifyListeners();
  }

  Future<void> fetchActiveDeliveries() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.riderActiveOrders);
      if (response.statusCode == 200 && response.data['data'] != null) {
        final list = response.data['data'] as List;
        _activeDeliveries = list.map((e) => DeliveryAssignmentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _errorMessage = 'Unable to refresh active assignments from dispatch.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.riderHistory);
      if (response.statusCode == 200 && response.data['data'] != null) {
        final list = response.data['data'] as List;
        _history = list.map((e) => DeliveryAssignmentModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _errorMessage = 'Unable to refresh trip logs from dispatch.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markArrived(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiEndpoints.riderMarkArrived,
        data: {'order_id': orderId},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        _updateLocalArrivedStatus(orderId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = response.data['message'] ?? 'Unable to mark doorstep arrival.';
    } catch (e) {
      if (e is DioException && e.response != null) {
        _errorMessage = e.response?.data['message'] ?? 'Failed to mark doorstep arrival.';
      } else {
        _errorMessage = 'Network connection failed. Could not mark doorstep arrival.';
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> verifyPickupOtp(int orderId, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiEndpoints.riderVerifyPickupOtp,
        data: {'order_id': orderId, 'otp': otp.trim()},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        _updateLocalOrderStatus(orderId, 'out_for_delivery');
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = response.data['message'] ?? 'Pickup verification failed.';
    } catch (e) {
      if (e is DioException && e.response != null) {
        _errorMessage = e.response?.data['message'] ?? 'Pickup verification failed.';
      } else {
        _errorMessage = 'Network connection failed. Could not verify pickup.';
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> verifyCustomerDeliveryOtp(int orderId, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        ApiEndpoints.riderVerifyDeliveryOtp,
        data: {'order_id': orderId, 'otp': otp.trim()},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        _updateLocalOrderStatus(orderId, 'delivered');
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = response.data['message'] ?? 'Customer delivery code invalid.';
    } catch (e) {
      if (e is DioException && e.response != null) {
        _errorMessage = e.response?.data['message'] ?? 'Customer delivery code invalid.';
      } else {
        _errorMessage = 'Network connection failed. Could not verify delivery OTP.';
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void _updateLocalArrivedStatus(int orderId) {
    final idx = _activeDeliveries.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _activeDeliveries[idx] = _activeDeliveries[idx].copyWith(hasRiderArrived: true);
    }
  }

  void _updateLocalOrderStatus(int orderId, String newStatus) {
    final idx = _activeDeliveries.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      final current = _activeDeliveries[idx];
      final updated = current.copyWith(
        orderStatus: newStatus,
        hasRiderArrived: newStatus == 'delivered' ? true : current.hasRiderArrived,
      );

      if (newStatus == 'delivered') {
        _activeDeliveries.removeAt(idx);
        _history.insert(0, updated);
      } else {
        _activeDeliveries[idx] = updated;
      }
    }
  }
}