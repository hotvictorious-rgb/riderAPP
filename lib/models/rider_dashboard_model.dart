class RiderDashboardModel {
  final int activeAssignmentsCount;
  final int completedTripsCount;
  final String shiftStatus;
  final String assignedCorridor;
  final double onTimeRatePercent;

  RiderDashboardModel({
    required this.activeAssignmentsCount,
    required this.completedTripsCount,
    this.shiftStatus = 'ON DUTY',
    this.assignedCorridor = 'Metropolitan Dispatch Zone',
    this.onTimeRatePercent = 99.4,
  });

  factory RiderDashboardModel.fromJson(Map<String, dynamic> json) {
    return RiderDashboardModel(
      activeAssignmentsCount: json['active_assignments_count'] ?? 0,
      completedTripsCount: json['completed_trips_count'] ?? 0,
      shiftStatus: json['shift_status'] ?? 'ON DUTY',
      assignedCorridor: json['assigned_corridor'] ?? 'Metropolitan Dispatch Zone',
      onTimeRatePercent: (json['on_time_rate'] as num?)?.toDouble() ?? 99.4,
    );
  }
}