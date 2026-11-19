// lib/widgets/rider_telemetry_card.dart
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class RiderTelemetryCard extends StatelessWidget {
  final int completedTrips;
  final int activeMissions;
  final String assignedCorridor;
  final String fleetName;
  final double onTimeRate;
  final VoidCallback? onViewMissions;

  const RiderTelemetryCard({
    super.key,
    required this.completedTrips,
    required this.activeMissions,
    required this.assignedCorridor,
    required this.fleetName,
    this.onTimeRate = 99.4,
    this.onViewMissions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top telemetry row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dispatchEmerald.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.25), width: 1.0),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.radar, size: 12, color: AppColors.dispatchEmerald),
                    SizedBox(width: 5),
                    Text(
                      'FLEET TELEMETRY • LIVE',
                      style: TextStyle(
                        color: AppColors.dispatchEmerald,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.25), width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 11, color: AppColors.primaryGold),
                    const SizedBox(width: 4),
                    Text(
                      '${onTimeRate.toStringAsFixed(1)}% On-Time',
                      style: const TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main metric: Completed Trips
          const Text(
            'Shift Deliveries Fulfilled',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$completedTrips',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Trips Completed',
                style: TextStyle(color: AppColors.dispatchEmerald, fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Symmetrical 2-column metrics
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Missions',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.navigation, size: 13, color: AppColors.primaryGold),
                          const SizedBox(width: 5),
                          Text(
                            '$activeMissions En Route',
                            style: const TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Assigned Corridor',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 13, color: AppColors.dispatchEmerald),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              assignedCorridor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Corporate Remuneration notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.corporate_fare, size: 14, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Corporate Fleet Remuneration • Settled directly by $fleetName',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
