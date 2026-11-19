// lib/widgets/rider_duty_switch_card.dart
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class RiderDutySwitchCard extends StatelessWidget {
  final bool isOnline;
  final String fleetName;
  final String vehicleType;
  final String licensePlate;
  final VoidCallback onToggle;

  const RiderDutySwitchCard({
    super.key,
    required this.isOnline,
    required this.fleetName,
    required this.vehicleType,
    required this.licensePlate,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOnline ? AppColors.dispatchEmerald.withOpacity(0.4) : AppColors.surfaceBorder,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.dispatchEmerald.withOpacity(0.15) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isOnline ? AppColors.dispatchEmerald.withOpacity(0.3) : AppColors.surfaceBorder,
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  isOnline ? Icons.radar : Icons.power_settings_new,
                  color: isOnline ? AppColors.dispatchEmerald : AppColors.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOnline ? AppColors.dispatchEmerald : AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? 'DUTY ACTIVE • ONLINE' : 'STANDBY • OFFLINE',
                          style: TextStyle(
                            color: isOnline ? AppColors.dispatchEmerald : AppColors.textMuted,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      fleetName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: isOnline,
                  onChanged: (_) => onToggle(),
                  activeColor: AppColors.dispatchEmerald,
                  activeTrackColor: AppColors.dispatchEmerald.withOpacity(0.25),
                  inactiveThumbColor: AppColors.textMuted,
                  inactiveTrackColor: AppColors.surfaceElevated,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.two_wheeler, size: 15, color: AppColors.primaryGold),
                    const SizedBox(width: 6),
                    Text(
                      vehicleType,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                  ),
                  child: Text(
                    licensePlate,
                    style: const TextStyle(
                      color: AppColors.primaryGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
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
