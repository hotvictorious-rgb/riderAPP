import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_dashboard_provider.dart';
import '../../providers/rider_delivery_provider.dart';

class RiderEarningsScreen extends StatelessWidget {
  const RiderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dash = Provider.of<RiderDashboardProvider>(context);
    final deliv = Provider.of<RiderDeliveryProvider>(context);

    final fleetName = dash.profile?.fleetCompany.isNotEmpty == true ? dash.profile!.fleetCompany : 'Employing Fleet';
    final completedTrips = dash.dashboardMetrics?.completedTripsCount ?? 0;
    final onTimeRate = dash.dashboardMetrics?.onTimeRatePercent ?? 100.0;
    final corridor = dash.dashboardMetrics?.assignedCorridor.isNotEmpty == true
        ? dash.dashboardMetrics!.assignedCorridor
        : (fleetName.isNotEmpty ? '$fleetName Dispatch Area' : 'Metropolitan Dispatch Zone');

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      appBar: AppBar(
        title: const Text('FLEET SETTLEMENT & PAYROLL'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Corporate Fleet Affiliation Hero
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E0E45), Color(0xFF100726)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.richGold.withOpacity(0.4), width: 1.5),
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
                          color: AppColors.richGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.richGold.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.corporate_fare, size: 13, color: AppColors.richGold),
                            SizedBox(width: 5),
                            Text('CORPORATE PAYROLL', style: TextStyle(color: AppColors.richGold, fontSize: 10, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.dispatchEmerald.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('ACTIVE EMPLOYMENT', style: TextStyle(color: AppColors.dispatchEmerald, fontSize: 9.5, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Employing Logistics Company', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    fleetName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_outlined, size: 16, color: AppColors.dispatchEmerald),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Zero Wallet Liability Model: In accordance with Victorious Market governance, couriers are salaried corporate employees. All trip commissions, delivery bonuses, and hourly compensation are disbursed directly by your fleet manager.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Telemetry & Shift Performance Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.obsidianCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.obsidianBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('FULFILLED TRIPS', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                          '$completedTrips',
                          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        const Text('Shift Certified', style: TextStyle(color: AppColors.dispatchEmerald, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.obsidianCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.obsidianBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ON-TIME RATE', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                          '${onTimeRate.toStringAsFixed(1)}%',
                          style: const TextStyle(color: AppColors.richGold, fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        const Text('Top Tier Courier', style: TextStyle(color: AppColors.richGold, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Corridor & Vehicle Info Card
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
                  const Text('ASSIGNED CORRIDOR & UNIT', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  _buildRow(Icons.map, 'Operating Corridor', corridor),
                  const Divider(color: AppColors.obsidianBorder, height: 18),
                  _buildRow(Icons.two_wheeler, 'Fleet Vehicle', dash.profile?.vehicleType ?? 'Fleet Vehicle'),
                  const Divider(color: AppColors.obsidianBorder, height: 18),
                  _buildRow(Icons.confirmation_number, 'Plate Number', dash.profile?.licensePlate ?? '--'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recent Deliveries Audit Trail
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RECENT SETTLED DELIVERIES', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                Text('${deliv.history.length} Logged', style: const TextStyle(color: AppColors.dispatchEmerald, fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 10),

            if (deliv.history.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.obsidianCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.obsidianBorder),
                ),
                alignment: Alignment.center,
                child: const Text('No deliveries logged for this shift yet.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              )
            else
              ...deliv.history.take(5).map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.obsidianCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.obsidianBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.orderNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('Recipient: ${item.customerName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.dispatchEmerald.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('SETTLED', style: TextStyle(color: AppColors.dispatchEmerald, fontSize: 9.5, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryPurple),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}
