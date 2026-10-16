import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_delivery_provider.dart';
import '../../widgets/active_delivery_card.dart';
import '../../widgets/doorstep_handover_manifest_dialog.dart';
import '../../widgets/shop_pickup_otp_dialog.dart';
import '../../widgets/delivery_attempt_failed_dialog.dart';

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
            onPressed: () {
              deliv.fetchActiveDeliveries();
              deliv.fetchActiveReturns();
            },
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
                      onPickupAction: () {
                        showDialog(
                          context: context,
                          builder: (_) => ShopPickupOtpDialog(
                            orderNumber: item.orderNumber,
                            shopName: item.shopName,
                            onVerify: (otp) => deliv.verifyPickupOtp(item.id, otp),
                          ),
                        ).then((success) {
                          if (success == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.dispatchEmerald,
                                content: Text('Shop Handover Verified! Order is now En Route.'),
                              ),
                            );
                          }
                        });
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
                          builder: (_) => DoorstepHandoverManifestDialog(
                            assignment: item,
                            onSubmit: (otp, manifest) async {
                              final res = await deliv.submitDoorstepHandover(
                                orderId: item.id,
                                otp: otp,
                                manifestItems: manifest,
                              );
                              if (context.mounted && res['success'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.dispatchEmerald,
                                    content: Text(res['message'] ?? 'Delivery Handover Certified! Logged to Fleet Dispatch.'),
                                  ),
                                );
                              }
                              return res;
                            },
                          ),
                        );
                      },
                      onDeliveryIssueAction: () {
                        showDialog(
                          context: context,
                          builder: (_) => DeliveryAttemptFailedDialog(
                            orderNumber: item.orderNumber,
                            customerName: item.customerName,
                            onSubmit: (reason, notes) => deliv.recordDeliveryAttemptFailed(
                              orderId: item.id,
                              reason: reason,
                              notes: notes,
                            ),
                          ),
                        ).then((res) {
                          if (res != null && res['success'] == true && context.mounted) {
                            final maxReached = res['max_attempts_reached'] == true;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: maxReached ? AppColors.dispatchAmber : AppColors.dispatchEmerald,
                                content: Text(
                                  maxReached
                                      ? 'Max attempts reached! Parcel moved to Returns tab for shop return.'
                                      : 'Failed attempt logged. Customer notified.',
                                ),
                              ),
                            );
                          }
                        });
                      },
                    );
                  },
                ),
    );
  }
}