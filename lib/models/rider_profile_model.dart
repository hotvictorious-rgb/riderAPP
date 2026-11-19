class RiderProfileModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final int? logisticsCompanyId;
  final String fleetCompany;
  final String vehicleType;
  final String licensePlate;
  final double rating;
  final bool isActive;
  final bool isOnline;
  final String? bankName;
  final String? bankCode;
  final String? accountNumber;
  final String? accountName;
  final bool isBankLocked;

  RiderProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.logisticsCompanyId,
    required this.fleetCompany,
    required this.vehicleType,
    required this.licensePlate,
    required this.rating,
    required this.isActive,
    required this.isOnline,
    this.bankName,
    this.bankCode,
    this.accountNumber,
    this.accountName,
    this.isBankLocked = true,
  });

  /// Invariant: All riders must belong to an active Logistics Company.
  bool get hasLogisticsCompany =>
      fleetCompany.trim().isNotEmpty &&
      fleetCompany.toLowerCase() != 'unassigned' &&
      fleetCompany.toLowerCase() != 'none';

  bool get hasBankDetails => (accountNumber ?? '').isNotEmpty && (bankName ?? '').isNotEmpty;

  factory RiderProfileModel.fromJson(Map<String, dynamic> json) {
    final payout = json['payout_bank'] as Map<String, dynamic>?;

    return RiderProfileModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Courier',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      logisticsCompanyId: json['logistics_company_id'] as int?,
      fleetCompany: json['fleet_company'] as String? ?? 'Unassigned Fleet',
      vehicleType: json['vehicle_type'] as String? ?? 'Fleet Vehicle',
      licensePlate: json['license_plate'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      isActive: json['is_active'] as bool? ?? true,
      isOnline: json['is_online'] as bool? ?? false,
      bankName: (json['bank_name'] ?? payout?['bank_name']) as String?,
      bankCode: (json['bank_code'] ?? payout?['bank_code']) as String?,
      accountNumber: (json['account_number'] ?? payout?['account_number']) as String?,
      accountName: (json['account_name'] ?? payout?['account_name']) as String?,
      isBankLocked: true,
    );
  }

  RiderProfileModel copyWith({bool? isOnline, String? fleetCompany}) {
    return RiderProfileModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      logisticsCompanyId: logisticsCompanyId,
      fleetCompany: fleetCompany ?? this.fleetCompany,
      vehicleType: vehicleType,
      licensePlate: licensePlate,
      rating: rating,
      isActive: isActive,
      isOnline: isOnline ?? this.isOnline,
      bankName: bankName,
      bankCode: bankCode,
      accountNumber: accountNumber,
      accountName: accountName,
      isBankLocked: isBankLocked,
    );
  }
}