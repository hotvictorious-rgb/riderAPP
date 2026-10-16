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
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOnline ? AppColors.dispatchEmerald.withOpacity(0.4) : AppColors.obsidianBorder,
          width: 1.5,
        ),
        boxShadow: isOnline
            ? [
                BoxShadow(
                  color: AppColors.dispatchEmerald.withOpacity(0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.dispatchEmerald.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOnline ? Icons.radar : Icons.power_settings_new,
                  color: isOnline ? AppColors.dispatchEmerald : AppColors.textMuted,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isOnline ? 'DUTY ACTIVE • ONLINE' : 'STANDBY • OFFLINE',
                          style: TextStyle(
                            color: isOnline ? AppColors.dispatchEmerald : AppColors.textMuted,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (isOnline) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.dispatchEmerald,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      fleetName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOnline,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.dispatchEmerald,
                activeTrackColor: AppColors.dispatchEmerald.withOpacity(0.3),
                inactiveThumbColor: AppColors.textMuted,
                inactiveTrackColor: Colors.black26,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.two_wheeler, size: 16, color: AppColors.richGold),
                    const SizedBox(width: 6),
                    Text(
                      vehicleType,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Text(
                  licensePlate,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}