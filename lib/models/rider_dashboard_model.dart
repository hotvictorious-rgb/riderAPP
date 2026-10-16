class RiderDashboardModel {
  final double walletBalance;
  final double todayEarnings;
  final double totalEarnings;
  final int activeAssignmentsCount;
  final int completedTripsCount;

  RiderDashboardModel({
    required this.walletBalance,
    required this.todayEarnings,
    required this.totalEarnings,
    required this.activeAssignmentsCount,
    required this.completedTripsCount,
  });

  factory RiderDashboardModel.fromJson(Map<String, dynamic> json) {
    return RiderDashboardModel(
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 14500.00,
      todayEarnings: (json['today_earnings'] as num?)?.toDouble() ?? 6200.00,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 98500.00,
      activeAssignmentsCount: json['active_assignments_count'] ?? 2,
      completedTripsCount: json['completed_trips_count'] ?? 48,
    );
  }
}