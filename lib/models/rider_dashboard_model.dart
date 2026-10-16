class RiderDashboardModel {
  final int activeAssignmentsCount;
  final int completedTripsCount;
  final String shiftStatus;
  final String assignedCorridor;
  final double onTimeRatePercent;

  RiderDashboardModel({
    required this.activeAssignmentsCount,
    required this.completedTripsCount,
    this.shiftStatus = 'STANDBY',
    this.assignedCorridor = 'Metropolitan Dispatch Zone',
    this.onTimeRatePercent = 100.0,
  });

  factory RiderDashboardModel.fromJson(Map<String, dynamic> json) {
    return RiderDashboardModel(
      activeAssignmentsCount: json['active_assignments_count'] as int? ?? 0,
      completedTripsCount: json['completed_trips_count'] as int? ?? 0,
      shiftStatus: json['shift_status'] as String? ?? 'STANDBY',
      assignedCorridor: json['assigned_corridor'] as String? ?? 'Metropolitan Dispatch Zone',
      onTimeRatePercent: (json['on_time_rate'] as num?)?.toDouble() ?? 100.0,
    );
  }
}