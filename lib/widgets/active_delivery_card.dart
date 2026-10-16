import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/delivery_assignment_model.dart';

class ActiveDeliveryCard extends StatelessWidget {
  final DeliveryAssignmentModel assignment;
  final VoidCallback onPickupAction;
  final VoidCallback onMarkArrivedAction;
  final VoidCallback onVerifyDeliveryAction;

  const ActiveDeliveryCard({
    super.key,
    required this.assignment,
    required this.onPickupAction,
    required this.onMarkArrivedAction,
    required this.onVerifyDeliveryAction,
  });

  @override
  Widget build(BuildContext context) {
    final isPickup = assignment.isReadyForPickup;
    final isDelivered = assignment.isDelivered;
    final isEnRoute = assignment.isOutForDelivery;
    final hasArrived = assignment.hasRiderArrived;

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
                  : AppColors.primaryPurple.withOpacity(0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Stage badge & Priority tag
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
                          : AppColors.primaryPurple.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPickup
                        ? AppColors.dispatchAmber.withOpacity(0.3)
                        : isDelivered
                            ? AppColors.dispatchEmerald.withOpacity(0.3)
                            : AppColors.primaryPurple.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  isPickup
                      ? 'STEP 1: PICKUP AT SHOP'
                      : isDelivered
                          ? 'DELIVERED & LOGGED TO FLEET'
                          : (hasArrived ? 'STEP 2: ARRIVED AT DOORSTEP' : 'STEP 2: OUT FOR DELIVERY'),
                  style: TextStyle(
                    color: isPickup
                        ? AppColors.dispatchAmber
                        : isDelivered
                            ? AppColors.dispatchEmerald
                            : (hasArrived ? AppColors.dispatchEmerald : AppColors.primaryPurple),
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

          // Order Number & Package Contents
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                assignment.orderNumber,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
              Text(
                '${assignment.itemsCount} ${assignment.itemsCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            assignment.itemsSummary,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.obsidianBorder),
          const SizedBox(height: 8),

          // Multi-Stop Route Nodes (Shop -> Customer)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.store, color: AppColors.dispatchAmber, size: 18),
                  Container(width: 1.5, height: 26, color: AppColors.obsidianBorder),
                  const Icon(Icons.location_on, color: AppColors.dispatchEmerald, size: 18),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop node
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            assignment.shopName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                        Text(
                          assignment.shopPhone,
                          style: const TextStyle(color: AppColors.dispatchAmber, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Text(assignment.shopAddress, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 14),

                    // Customer node
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            assignment.customerName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                        Text(
                          assignment.customerPhone,
                          style: const TextStyle(color: AppColors.dispatchEmerald, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Text(
                      '${assignment.deliveryAddress} (${assignment.destinationLga})',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Actions matching Backend Lifecycle
          if (isPickup) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.dispatchAmber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.dispatchAmber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.key, size: 16, color: AppColors.dispatchAmber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Courier PIN: ${assignment.pickupPin} (Present to Shop Staff)',
                      style: const TextStyle(color: AppColors.dispatchAmber, fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPickupAction,
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Confirm Shop Handover & Start Route'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dispatchAmber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else if (isEnRoute) ...[
            if (!hasArrived) ...[
              // Stage 2: Courier is riding, taps "I'm Here" to alert customer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onMarkArrivedAction,
                  icon: const Icon(Icons.location_on, size: 16),
                  label: const Text("📍 I'm Here • Notify Doorstep Arrival"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ] else ...[
              // Arrival notice
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.dispatchEmerald.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications_active, size: 16, color: AppColors.dispatchEmerald),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Customer phone alerted at doorstep! Request 6-digit delivery PIN.',
                        style: TextStyle(color: AppColors.dispatchEmerald, fontSize: 11.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onVerifyDeliveryAction,
                icon: const Icon(Icons.verified_user, size: 16),
                label: const Text('Enter Customer Delivery PIN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dispatchEmerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}