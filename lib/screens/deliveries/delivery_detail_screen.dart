import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/delivery_assignment_model.dart';
import '../../providers/rider_delivery_provider.dart';
import '../../widgets/doorstep_handover_manifest_dialog.dart';
import '../../widgets/shop_pickup_otp_dialog.dart';
import '../../widgets/delivery_attempt_failed_dialog.dart';

class DeliveryDetailScreen extends StatefulWidget {
  final DeliveryAssignmentModel assignment;

  const DeliveryDetailScreen({super.key, required this.assignment});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  late DeliveryAssignmentModel _current;

  @override
  void initState() {
    super.initState();
    _current = widget.assignment;
  }

  void _showSnack(String msg, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess ? AppColors.dispatchEmerald : AppColors.urgentRed,
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deliv = Provider.of<RiderDeliveryProvider>(context);

    // Keep _current in sync if found in activeDeliveries
    final match = deliv.activeDeliveries.where((d) => d.id == _current.id);
    if (match.isNotEmpty) {
      _current = match.first;
    }

    final isPickup = _current.isReadyForPickup;
    final isEnRoute = _current.isOutForDelivery;
    final isDelivered = _current.isDelivered;
    final hasArrived = _current.hasRiderArrived;

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      appBar: AppBar(
        title: Text('MISSION ${_current.orderNumber}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status HUD Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E0E45), Color(0xFF100726)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryPurple.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _current.orderNumber,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Corridor: ${_current.destinationLga}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isPickup
                          ? AppColors.dispatchAmber.withOpacity(0.18)
                          : (isDelivered ? AppColors.dispatchEmerald.withOpacity(0.18) : AppColors.primaryPurple.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPickup
                            ? AppColors.dispatchAmber
                            : (isDelivered ? AppColors.dispatchEmerald : AppColors.primaryPurple),
                      ),
                    ),
                    child: Text(
                      isPickup ? 'READY FOR PICKUP' : (isDelivered ? 'DELIVERED' : (hasArrived ? 'AT DOORSTEP' : 'EN ROUTE')),
                      style: TextStyle(
                        color: isPickup
                            ? AppColors.dispatchAmber
                            : (isDelivered ? AppColors.dispatchEmerald : Colors.white),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Milestone Tracker
            _buildMilestoneStepper(isPickup, isEnRoute, hasArrived, isDelivered),
            const SizedBox(height: 16),

            // Origin: Vendor Shop Card
            _buildContactCard(
              title: 'STEP 1: PICKUP VENDOR SHOP',
              name: _current.shopName,
              address: _current.shopAddress,
              phone: _current.shopPhone,
              icon: Icons.store,
              accentColor: AppColors.dispatchAmber,
              pinLabel: isPickup ? 'Courier PIN: ${_current.pickupPin ?? "Required"}' : 'Handover Certified ✓',
            ),
            const SizedBox(height: 14),

            // Destination: Customer Recipient Card
            _buildContactCard(
              title: 'STEP 2: CUSTOMER DOORSTEP',
              name: _current.customerName,
              address: '${_current.deliveryAddress} (${_current.destinationLga})',
              phone: _current.customerPhone,
              icon: Icons.location_on,
              accentColor: AppColors.dispatchEmerald,
              pinLabel: isDelivered ? 'Delivery PIN Verified ✓' : (hasArrived ? 'Doorstep Alert Sent • Request PIN' : 'Pending Arrival'),
            ),
            const SizedBox(height: 16),

            // Manifest Items Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.obsidianCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.obsidianBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PACKAGE CONTENTS & MANIFEST',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                      Text(
                        '${_current.itemsCount} Items',
                        style: const TextStyle(color: AppColors.richGold, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_current.manifestItems.isNotEmpty)
                    ..._current.manifestItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.productName,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              '${item.orderedQuantity}x',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Text(
                      _current.itemsSummary,
                      style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Primary Action Buttons
            if (isPickup) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final success = await showDialog<bool>(
                      context: context,
                      builder: (_) => ShopPickupOtpDialog(
                        orderNumber: _current.orderNumber,
                        shopName: _current.shopName,
                        onVerify: (otp) => deliv.verifyPickupOtp(_current.id, otp),
                      ),
                    );
                    if (success == true) {
                      _showSnack('Shop Handover Verified! Order is now En Route.');
                      if (mounted) setState(() {});
                    }
                  },
                  icon: const Icon(Icons.store, size: 18),
                  label: const Text('Enter Merchant Pickup PIN & Start Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dispatchAmber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ] else if (isEnRoute) ...[
              if (!hasArrived) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final success = await deliv.markArrived(_current.id);
                      _showSnack(
                        success ? '📍 Doorstep Arrival Logged! Customer notified.' : (deliv.errorMessage ?? 'Failed to log arrival.'),
                        isSuccess: success,
                      );
                      if (success && mounted) setState(() {});
                    },
                    icon: const Icon(Icons.location_on, size: 18),
                    label: const Text("📍 I'm Here • Notify Doorstep Arrival"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showDialog<bool>(
                      context: context,
                      builder: (_) => DoorstepHandoverManifestDialog(
                        assignment: _current,
                        onSubmit: (otp, manifest) => deliv.submitDoorstepHandover(
                          orderId: _current.id,
                          otp: otp,
                          manifestItems: manifest,
                        ),
                      ),
                    );
                    if (result == true) {
                      _showSnack('Doorstep Handover Certified! Logged to Fleet Dispatch.');
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.verified_user, size: 18),
                  label: const Text('Complete Doorstep Handover (PIN & Manifest)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dispatchEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final res = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (_) => DeliveryAttemptFailedDialog(
                        orderNumber: _current.orderNumber,
                        customerName: _current.customerName,
                        onSubmit: (reason, notes) => deliv.recordDeliveryAttemptFailed(
                          orderId: _current.id,
                          reason: reason,
                          notes: notes,
                        ),
                      ),
                    );
                    if (res != null && res['success'] == true) {
                      final maxReached = res['max_attempts_reached'] == true;
                      _showSnack(
                        maxReached
                            ? 'Max attempts reached! Parcel moved to Returns tab for shop return.'
                            : 'Delivery attempt failure logged. Customer alerted.',
                        isSuccess: !maxReached,
                      );
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.report_problem_outlined, size: 16, color: AppColors.urgentRed),
                  label: const Text(
                    'Customer Unreachable? Report Failed Attempt',
                    style: TextStyle(color: AppColors.urgentRed, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.urgentRed.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ] else if (isDelivered) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dispatchEmerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.dispatchEmerald, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Mission Successfully Fulfilled',
                      style: TextStyle(color: AppColors.dispatchEmerald, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneStepper(bool isPickup, bool isEnRoute, bool hasArrived, bool isDelivered) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.obsidianBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMilestoneNode('1. Pickup', isPickup, !isPickup),
          _buildMilestoneLine(!isPickup),
          _buildMilestoneNode('2. En Route', isEnRoute && !hasArrived, hasArrived || isDelivered),
          _buildMilestoneLine(hasArrived || isDelivered),
          _buildMilestoneNode('3. Doorstep', hasArrived && !isDelivered, isDelivered),
          _buildMilestoneLine(isDelivered),
          _buildMilestoneNode('4. Done', false, isDelivered),
        ],
      ),
    );
  }

  Widget _buildMilestoneNode(String label, bool isCurrent, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.dispatchEmerald
                : (isCurrent ? AppColors.primaryPurple : Colors.white.withOpacity(0.06)),
            border: Border.all(
              color: isCurrent ? AppColors.primaryPurple : (isCompleted ? AppColors.dispatchEmerald : AppColors.obsidianBorder),
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : (isCurrent ? Icons.circle : Icons.circle_outlined),
            size: isCompleted ? 16 : 10,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isCompleted || isCurrent ? Colors.white : AppColors.textMuted,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneLine(bool isPassed) {
    return Expanded(
      child: Container(
        height: 2,
        color: isPassed ? AppColors.dispatchEmerald : AppColors.obsidianBorder,
        margin: const EdgeInsets.only(bottom: 14),
      ),
    );
  }

  Widget _buildContactCard({
    required String title,
    required String name,
    required String address,
    required String phone,
    required IconData icon,
    required Color accentColor,
    required String pinLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.obsidianCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  pinLabel,
                  style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      address,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.3),
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Contact: $phone',
                        style: TextStyle(color: accentColor, fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
