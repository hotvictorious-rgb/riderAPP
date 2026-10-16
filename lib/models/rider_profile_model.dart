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
  });

  /// Invariant: All riders must belong to an active Logistics Company.
  bool get hasLogisticsCompany =>
      fleetCompany.trim().isNotEmpty &&
      fleetCompany.toLowerCase() != 'unassigned' &&
      fleetCompany.toLowerCase() != 'none';

  factory RiderProfileModel.fromJson(Map<String, dynamic> json) {
    return RiderProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Musa Haruna',
      email: json['email'] ?? 'rider@speedyfleet.ng',
      phone: json['phone'] ?? '+234 805 555 6677',
      logisticsCompanyId: json['logistics_company_id'],
      fleetCompany: json['fleet_company'] ?? 'Speedy Parcel Express',
      vehicleType: json['vehicle_type'] ?? 'Motorbike (Bajaj Boxer)',
      licensePlate: json['license_plate'] ?? 'KJA-104-XY',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.92,
      isActive: json['is_active'] ?? true,
      isOnline: json['is_online'] ?? true,
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
    );
  }
}