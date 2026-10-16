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
      appBar: AppBar(title: const Text('ACTIVE DISPATCH TRIPS')),
      body: deliv.activeDeliveries.isEmpty
          ? const Center(child: Text('No active assignments', style: TextStyle(color: AppColors.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deliv.activeDeliveries.length,
              itemBuilder: (context, idx) {
                final item = deliv.activeDeliveries[idx];
                return ActiveDeliveryCard(
                  assignment: item,
                  onAction: () {
                    if (item.isReadyForPickup) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.dispatchAmber,
                          content: Text(
                            'Present 6-digit Courier PIN [${item.pickupPin}] to vendor staff.',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
                          ),
                        ),
                      );
                      deliv.verifyPickupOtp(item.id, item.pickupPin ?? '482910');
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => CustomerDeliveryOtpDialog(
                          orderNumber: item.orderNumber,
                          customerName: item.customerName,
                          deliveryCharge: item.deliveryCharge,
                          onVerify: (otp) {
                            deliv.verifyCustomerDeliveryOtp(item.id, otp);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.dispatchEmerald,
                                content: Text('Delivery Handover Certified! Fee credited to wallet.'),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}