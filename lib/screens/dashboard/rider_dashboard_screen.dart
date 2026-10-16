import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_dashboard_provider.dart';
import '../../providers/rider_delivery_provider.dart';
import '../../widgets/active_delivery_card.dart';
import '../../widgets/customer_delivery_otp_dialog.dart';
import '../../widgets/rider_duty_switch_card.dart';
import '../../widgets/rider_earnings_card.dart';
import '../profile/rider_profile_screen.dart';

class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({super.key});

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RiderDashboardProvider>(context, listen: false).fetchDashboard();
      Provider.of<RiderDeliveryProvider>(context, listen: false).fetchActiveDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dash = Provider.of<RiderDashboardProvider>(context);
    final deliv = Provider.of<RiderDeliveryProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      appBar: AppBar(
        title: const Text('DISPATCH RADAR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RiderProfileScreen()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await dash.fetchDashboard();
          await deliv.fetchActiveDeliveries();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Duty Status Switch Card
              RiderDutySwitchCard(
                isOnline: dash.isDutyOnline,
                fleetName: dash.profile?.fleetCompany ?? 'Speedy Parcel Express',
                vehicleType: dash.profile?.vehicleType ?? 'Motorbike (Bajaj Boxer)',
                licensePlate: dash.profile?.licensePlate ?? 'KJA-104-XY',
                onToggle: () => dash.toggleDuty(),
              ),
              const SizedBox(height: 16),

              // Wallet & Daily Telemetry Card
              RiderEarningsCard(
                walletBalance: dash.dashboardMetrics?.walletBalance ?? 14500.00,
                todayEarnings: dash.dashboardMetrics?.todayEarnings ?? 6200.00,
                completedTrips: dash.dashboardMetrics?.completedTripsCount ?? 48,
                onWithdraw: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Instant withdrawal request submitted to Access Bank.')),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Active Assignments Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ACTIVE ASSIGNMENTS',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  Text(
                    '${deliv.activeDeliveries.length} Pending Handover',
                    style: const TextStyle(color: AppColors.dispatchEmerald, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (deliv.activeDeliveries.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.obsidianCard, borderRadius: BorderRadius.circular(16)),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppColors.dispatchEmerald, size: 36),
                      SizedBox(height: 8),
                      Text('All assigned packages delivered!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      Text('Stay online to receive dispatch alerts.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                )
              else
                ...deliv.activeDeliveries.map(
                  (a) => ActiveDeliveryCard(
                    assignment: a,
                    onAction: () {
                      if (a.isReadyForPickup) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.dispatchAmber,
                            content: Text(
                              'Present 6-digit Courier PIN [${a.pickupPin}] to shop counter staff to release package.',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
                            ),
                          ),
                        );
                        deliv.verifyPickupOtp(a.id, a.pickupPin ?? '482910');
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => CustomerDeliveryOtpDialog(
                            orderNumber: a.orderNumber,
                            customerName: a.customerName,
                            deliveryCharge: a.deliveryCharge,
                            onVerify: (otp) {
                              deliv.verifyCustomerDeliveryOtp(a.id, otp);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.dispatchEmerald,
                                  content: Text('Delivery Certified! ₦2,500.00 credited to Rider Wallet.'),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}