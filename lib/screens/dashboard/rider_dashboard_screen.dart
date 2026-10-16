import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_dashboard_provider.dart';
import '../../providers/rider_delivery_provider.dart';
import '../../widgets/active_delivery_card.dart';
import '../../widgets/doorstep_handover_manifest_dialog.dart';
import '../../widgets/shop_pickup_otp_dialog.dart';
import '../../widgets/delivery_attempt_failed_dialog.dart';
import '../../widgets/rider_duty_switch_card.dart';
import '../../widgets/rider_telemetry_card.dart';
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
      Provider.of<RiderDeliveryProvider>(context, listen: false).fetchActiveReturns();
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
            icon: const Icon(Icons.person_outline),
            tooltip: 'Courier Profile',
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
          await deliv.fetchActiveReturns();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Duty Status Switch Card
              RiderDutySwitchCard(
                isOnline: dash.isDutyOnline,
                fleetName: dash.profile?.fleetCompany ?? '--',
                vehicleType: dash.profile?.vehicleType.isNotEmpty == true ? dash.profile!.vehicleType : 'Fleet Vehicle',
                licensePlate: dash.profile?.licensePlate.isNotEmpty == true ? dash.profile!.licensePlate : '--',
                onToggle: () => dash.toggleDuty(),
              ),
              const SizedBox(height: 16),

              // Operational Telemetry HUD Card
              RiderTelemetryCard(
                completedTrips: dash.dashboardMetrics?.completedTripsCount ?? 0,
                activeMissions: deliv.activeDeliveries.length,
                assignedCorridor: dash.dashboardMetrics?.assignedCorridor.isNotEmpty == true
                    ? dash.dashboardMetrics!.assignedCorridor
                    : (dash.profile?.fleetCompany ?? 'Metropolitan Dispatch Zone'),
                fleetName: dash.profile?.fleetCompany ?? '--',
                onTimeRate: dash.dashboardMetrics?.onTimeRatePercent ?? 100.0,
              ),
              const SizedBox(height: 24),

              // Active Assignments Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ACTIVE ASSIGNMENTS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
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
                    onPickupAction: () {
                      showDialog(
                        context: context,
                        builder: (_) => ShopPickupOtpDialog(
                          orderNumber: a.orderNumber,
                          shopName: a.shopName,
                          onVerify: (otp, livePhoto) => deliv.verifyPickupOtp(a.id, otp, livePhoto: livePhoto),
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
                      final success = await deliv.markArrived(a.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: success ? AppColors.dispatchEmerald : AppColors.urgentRed,
                            content: Text(
                              success
                                  ? 'ðŸ“ Doorstep Arrival Logged! Customer notified.'
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
                          assignment: a,
                          onSubmit: (otp, manifest, overallPhoto, itemDefectPhotos) async { final res = await deliv.submitDoorstepHandover(orderId: a.id, otp: otp, manifestItems: manifest, overallPhoto: overallPhoto, itemDefectPhotos: itemDefectPhotos);
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
                          orderNumber: a.orderNumber,
                          customerName: a.customerName,
                          onSubmit: (reason, notes, livePhoto) => deliv.recordDeliveryAttemptFailed(orderId: a.id, reason: reason, notes: notes, livePhoto: livePhoto),
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
