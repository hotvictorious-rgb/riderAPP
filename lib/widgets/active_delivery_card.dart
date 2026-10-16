import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/delivery_assignment_model.dart';

class ActiveDeliveryCard extends StatelessWidget {
  final DeliveryAssignmentModel assignment;
  final VoidCallback onAction;

  const ActiveDeliveryCard({
    super.key,
    required this.assignment,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isPickup = assignment.isReadyForPickup;
    final isDelivered = assignment.isDelivered;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPickup
              ? AppColors.dispatchAmber.withOpacity(0.4)
              : isDelivered
                  ? AppColors.dispatchEmerald.withOpacity(0.4)
                  : AppColors.primaryPurple.withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPickup
                      ? AppColors.dispatchAmber.withOpacity(0.15)
                      : isDelivered
                          ? AppColors.dispatchEmerald.withOpacity(0.15)
                          : AppColors.primaryPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPickup
                      ? 'STEP 1: PICKUP AT SHOP'
                      : isDelivered
                          ? 'DELIVERED & LOGGED TO FLEET'
                          : 'STEP 2: OUT FOR DELIVERY',
                  style: TextStyle(
                    color: isPickup
                        ? AppColors.dispatchAmber
                        : isDelivered
                            ? AppColors.dispatchEmerald
                            : AppColors.primaryPurple,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.richGold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.richGold.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, size: 12, color: AppColors.richGold),
                    const SizedBox(width: 3),
                    Text(
                      assignment.dispatchCategory,
                      style: const TextStyle(
                        color: AppColors.richGold,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            assignment.orderNumber,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(assignment.itemsSummary, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          const Divider(color: AppColors.obsidianBorder),
          const SizedBox(height: 8),

          // Route Nodes
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                children: [
                  Icon(Icons.store, color: AppColors.dispatchAmber, size: 18),
                  SizedBox(height: 14),
                  Icon(Icons.location_on, color: AppColors.dispatchEmerald, size: 18),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(assignment.shopName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    Text(assignment.shopAddress, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 12),
                    Text(assignment.customerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    Text(assignment.deliveryAddress, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          if (!isDelivered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(isPickup ? Icons.lock_clock : Icons.verified_user, size: 16),
                label: Text(
                  isPickup
                      ? 'Present Courier PIN (${assignment.pickupPin})'
                      : 'Enter Customer Handover PIN',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPickup ? AppColors.dispatchAmber : AppColors.primaryPurple,
                  foregroundColor: isPickup ? Colors.black : Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}