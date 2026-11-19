// lib/widgets/active_delivery_card.dart
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/courier_contact_helper.dart';
import '../models/delivery_assignment_model.dart';
import '../screens/deliveries/delivery_detail_screen.dart';

class ActiveDeliveryCard extends StatelessWidget {
  final DeliveryAssignmentModel assignment;
  final VoidCallback onPickupAction;
  final VoidCallback onMarkArrivedAction;
  final VoidCallback onVerifyDeliveryAction;
  final VoidCallback? onDeliveryIssueAction;

  const ActiveDeliveryCard({
    super.key,
    required this.assignment,
    required this.onPickupAction,
    required this.onMarkArrivedAction,
    required this.onVerifyDeliveryAction,
    this.onDeliveryIssueAction,
  });

  @override
  Widget build(BuildContext context) {
    final isPickup = assignment.isReadyForPickup;
    final isDelivered = assignment.isDelivered;
    final isEnRoute = assignment.isOutForDelivery;
    final hasArrived = assignment.hasRiderArrived;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPickup
              ? AppColors.primaryGold.withOpacity(0.35)
              : isDelivered
                  ? AppColors.dispatchEmerald.withOpacity(0.35)
                  : hasArrived
                      ? AppColors.dispatchEmerald.withOpacity(0.4)
                      : AppColors.surfaceBorder,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DeliveryDetailScreen(assignment: assignment)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            ? AppColors.primaryGold.withOpacity(0.12)
                            : isDelivered
                                ? AppColors.dispatchEmerald.withOpacity(0.12)
                                : hasArrived
                                    ? AppColors.dispatchEmerald.withOpacity(0.12)
                                    : AppColors.radarBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPickup
                              ? AppColors.primaryGold.withOpacity(0.3)
                              : isDelivered
                                  ? AppColors.dispatchEmerald.withOpacity(0.3)
                                  : hasArrived
                                      ? AppColors.dispatchEmerald.withOpacity(0.3)
                                      : AppColors.radarBlue.withOpacity(0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        isPickup
                            ? 'STEP 1: PICKUP AT SHOP'
                            : isDelivered
                                ? 'DELIVERED & LOGGED'
                                : (hasArrived ? 'STEP 2: AT DOORSTEP' : 'STEP 2: EN ROUTE'),
                        style: TextStyle(
                          color: isPickup
                              ? AppColors.primaryGold
                              : isDelivered
                                  ? AppColors.dispatchEmerald
                                  : (hasArrived ? AppColors.dispatchEmerald : AppColors.radarBlue),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.flash_on, size: 11, color: AppColors.primaryGold),
                          const SizedBox(width: 3),
                          Text(
                            assignment.dispatchCategory,
                            style: const TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${assignment.itemsCount} ${assignment.itemsCount == 1 ? 'item' : 'items'}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                if (assignment.itemsSummary.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    assignment.itemsSummary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(color: AppColors.surfaceBorder, height: 1),
                const SizedBox(height: 12),

                // Multi-Stop Route Nodes (Shop -> Customer)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.store, color: AppColors.primaryGold, size: 13),
                        ),
                        Container(width: 1.5, height: 32, color: AppColors.surfaceBorder),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.dispatchEmerald.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: AppColors.dispatchEmerald, size: 13),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
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
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                              if (assignment.shopPhone.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => CourierContactHelper.callPhone(assignment.shopPhone),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.phone, size: 11, color: AppColors.primaryGold),
                                            const SizedBox(width: 4),
                                            Text(
                                              assignment.shopPhone,
                                              style: const TextStyle(color: AppColors.primaryGold, fontSize: 10.5, fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    InkWell(
                                      onTap: () => CourierContactHelper.openWhatsApp(
                                        assignment.shopPhone,
                                        orderNumber: assignment.orderNumber,
                                        recipientName: assignment.shopName,
                                        isShop: true,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: AppColors.dispatchEmerald.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.3), width: 1.0),
                                        ),
                                        child: const Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.dispatchEmerald),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          Text(assignment.shopAddress, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          const SizedBox(height: 16),

                          // Customer node
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  assignment.customerName,
                                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                              if (assignment.customerPhone.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => CourierContactHelper.callPhone(assignment.customerPhone),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.phone, size: 11, color: AppColors.dispatchEmerald),
                                            const SizedBox(width: 4),
                                            Text(
                                              assignment.customerPhone,
                                              style: const TextStyle(color: AppColors.dispatchEmerald, fontSize: 10.5, fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    InkWell(
                                      onTap: () => CourierContactHelper.openWhatsApp(
                                        assignment.customerPhone,
                                        orderNumber: assignment.orderNumber,
                                        recipientName: assignment.customerName,
                                        isShop: false,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: AppColors.dispatchEmerald.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.3), width: 1.0),
                                        ),
                                        child: const Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.dispatchEmerald),
                                      ),
                                    ),
                                  ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryGold.withOpacity(0.3), width: 1.0),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, size: 15, color: AppColors.primaryGold),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Request 6-digit Handover PIN from Shop Staff at Counter',
                            style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: onPickupAction,
                      icon: const Icon(Icons.store, size: 16),
                      label: const Text('Enter Merchant Pickup PIN & Start Route'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ] else if (isEnRoute) ...[
                  if (!hasArrived) ...[
                    // Stage 2: Courier is riding, taps "I'm Here" to alert customer
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: onMarkArrivedAction,
                        icon: const Icon(Icons.location_on, size: 16),
                        label: const Text("📍 I'm Here • Notify Doorstep Arrival"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.radarBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    // Arrival notice
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.dispatchEmerald.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.3), width: 1.0),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.notifications_active, size: 15, color: AppColors.dispatchEmerald),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Customer phone alerted at doorstep! Request 6-digit delivery PIN.',
                              style: TextStyle(color: AppColors.dispatchEmerald, fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: onVerifyDeliveryAction,
                      icon: const Icon(Icons.verified_user, size: 16),
                      label: const Text('Complete Doorstep Handover (PIN & Manifest)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dispatchEmerald,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  if (onDeliveryIssueAction != null) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: onDeliveryIssueAction,
                        icon: const Icon(Icons.report_problem_outlined, size: 14, color: AppColors.urgentRed),
                        label: const Text(
                          'Customer Unreachable? Report Failed Attempt',
                          style: TextStyle(color: AppColors.urgentRed, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
