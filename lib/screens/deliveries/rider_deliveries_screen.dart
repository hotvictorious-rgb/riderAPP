import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_delivery_provider.dart';
import '../../widgets/active_delivery_card.dart';
import '../../widgets/customer_delivery_otp_dialog.dart';

class RiderDeliveriesScreen extends StatelessWidget {
  const RiderDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deliv = Provider.of<RiderDeliveryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      appBar: AppBar(
        title: const Text('ACTIVE DISPATCH MISSIONS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => deliv.fetchActiveDeliveries(),
          ),
        ],
      ),
      body: deliv.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : deliv.activeDeliveries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text('No active missions assigned', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      const SizedBox(height: 4),
                      const Text('Remain on duty to receive automatic dispatch alerts.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: deliv.activeDeliveries.length,
                  itemBuilder: (context, idx) {
                    final item = deliv.activeDeliveries[idx];
                    return ActiveDeliveryCard(
                      assignment: item,
                      onPickupAction: () async {
                        final success = await deliv.verifyPickupOtp(item.id, item.pickupPin ?? '482910');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: success ? AppColors.dispatchEmerald : AppColors.urgentRed,
                              content: Text(
                                success
                                    ? 'Shop Handover Verified! Order is now En Route.'
                                    : (deliv.errorMessage ?? 'Pickup verification failed.'),
                              ),
                            ),
                          );
                        }
                      },
                      onMarkArrivedAction: () async {
                        final success = await deliv.markArrived(item.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: success ? AppColors.dispatchEmerald : AppColors.urgentRed,
                              content: Text(
                                success
                                    ? '📍 Doorstep Arrival Logged! Customer notified.'
                                    : (deliv.errorMessage ?? 'Failed to log arrival.'),
                              ),
                            ),
                          );
                        }
                      },
                      onVerifyDeliveryAction: () {
                        showDialog(
                          context: context,
                          builder: (_) => CustomerDeliveryOtpDialog(
                            orderNumber: item.orderNumber,
                            customerName: item.customerName,
                            onVerify: (otp) async {
                              final success = await deliv.verifyCustomerDeliveryOtp(item.id, otp);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: success ? AppColors.dispatchEmerald : AppColors.urgentRed,
                                    content: Text(
                                      success
                                          ? 'Delivery Handover Certified! Logged to Fleet Dispatch.'
                                          : (deliv.errorMessage ?? 'Invalid delivery code.'),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}