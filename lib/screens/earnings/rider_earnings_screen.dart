import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/courier_contact_helper.dart';
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
      backgroundColor: AppColors.background,
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.35), width: 1.0),
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
                          color: AppColors.primaryGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryGold.withOpacity(0.25), width: 1.0),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.corporate_fare, size: 13, color: AppColors.primaryGold),
                            SizedBox(width: 5),
                            Text('CORPORATE PAYROLL', style: TextStyle(color: AppColors.primaryGold, fontSize: 9.5, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.dispatchEmerald.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.25), width: 1.0),
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
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_outlined, size: 16, color: AppColors.dispatchEmerald),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Corporate Payroll: Tri-weekly and daily trip allowances, delivery fuel subsidies, and completed mission bonuses are disbursed directly by your fleet manager.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGold,
                        side: const BorderSide(color: AppColors.primaryGold, width: 1.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.support_agent, size: 16),
                      label: const Text('Contact Fleet Manager / Dispatch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      onPressed: () => CourierContactHelper.callDispatchHotline(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Disbursed Payout Destination Account (Read-Only under Policy L-20)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryGold, size: 16),
                          SizedBox(width: 7),
                          Text(
                            'DISBURSEMENT PAYOUT DESTINATION',
                            style: TextStyle(
                              color: AppColors.primaryGold,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryGold.withOpacity(0.25), width: 1.0),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline, size: 10, color: AppColors.primaryGold),
                            SizedBox(width: 4),
                            Text('LOCKED', style: TextStyle(color: AppColors.primaryGold, fontSize: 9, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (dash.profile?.hasBankDetails == true) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Registered Bank', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        Text(
                          dash.profile!.bankName!,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('NUBAN Account', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        Text(
                          dash.profile!.accountNumber!,
                          style: const TextStyle(
                            color: AppColors.primaryGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Legal Account Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        Flexible(
                          child: Text(
                            dash.profile!.accountName ?? '',
                            style: const TextStyle(color: AppColors.dispatchEmerald, fontSize: 12.5, fontWeight: FontWeight.w800),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'Payout account pending assignment by Platform Super Admin.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_clock_outlined, size: 14, color: AppColors.primaryGold),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Remuneration Security: Delivery commissions and allowance settlements are transferred exclusively to this account. Payout destination cannot be modified by couriers in-app.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Telemetry & Shift Performance Grid
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('FULFILLED TRIPS', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                          '$completedTrips',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w900),
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
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ON-TIME RATE', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(
                          '${onTimeRate.toStringAsFixed(1)}%',
                          style: const TextStyle(color: AppColors.primaryGold, fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        const Text('Top Tier Courier', style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.w700)),
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ASSIGNED CORRIDOR & UNIT', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  _buildRow(Icons.map, 'Operating Corridor', corridor),
                  const Divider(color: AppColors.surfaceBorder, height: 18),
                  _buildRow(Icons.two_wheeler, 'Fleet Vehicle', dash.profile?.vehicleType ?? 'Fleet Vehicle'),
                  const Divider(color: AppColors.surfaceBorder, height: 18),
                  _buildRow(Icons.confirmation_number, 'Plate Number', dash.profile?.licensePlate ?? '--'),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Recent Deliveries Audit Trail
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RECENT SETTLED DELIVERIES', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.dispatchEmerald.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${deliv.history.length} Logged', style: const TextStyle(color: AppColors.dispatchEmerald, fontSize: 10.5, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (deliv.history.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
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
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.orderNumber, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
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
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
          ),
          child: Icon(icon, size: 16, color: AppColors.primaryGold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}
