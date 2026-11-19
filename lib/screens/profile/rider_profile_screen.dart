import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_auth_provider.dart';
import '../../providers/rider_dashboard_provider.dart';
import '../../providers/rider_notification_provider.dart';
import '../auth/rider_login_screen.dart';
import '../earnings/rider_earnings_screen.dart';
import '../notifications/rider_notifications_screen.dart';

class RiderProfileScreen extends StatelessWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<RiderAuthProvider>(context);
    final dash = Provider.of<RiderDashboardProvider>(context);

    final rider = auth.currentRider ?? dash.profile;
    final riderName = (rider != null && rider.name.isNotEmpty) ? rider.name : 'Rider Courier';
    final riderEmail = (rider != null && rider.email.isNotEmpty) ? rider.email : '--';
    final riderPhone = (rider != null && rider.phone.isNotEmpty) ? rider.phone : '--';
    final fleetName = (rider != null && rider.fleetCompany.isNotEmpty) ? rider.fleetCompany : 'Unassigned Fleet';
    final vehicleType = (rider != null && rider.vehicleType.isNotEmpty) ? rider.vehicleType : 'Fleet Vehicle';
    final licensePlate = (rider != null && rider.licensePlate.isNotEmpty) ? rider.licensePlate : '--';
    final corridor = dash.dashboardMetrics?.assignedCorridor.isNotEmpty == true
        ? dash.dashboardMetrics!.assignedCorridor
        : (fleetName.isNotEmpty ? '$fleetName Dispatch Area' : 'Metropolitan Dispatch Zone');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FLEET COURIER PROFILE'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Courier Identity Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGold.withOpacity(0.35), width: 1.5),
                    ),
                    child: const Icon(Icons.two_wheeler, color: AppColors.primaryGold, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          riderName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          riderEmail,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.dispatchEmerald.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.25), width: 1.0),
                              ),
                              child: const Text(
                                'ACTIVE COURIER',
                                style: TextStyle(
                                  color: AppColors.dispatchEmerald,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.primaryGold, size: 12),
                                const SizedBox(width: 3),
                                Text(
                                  '${(rider?.rating ?? 5.0).toStringAsFixed(1)} Rating',
                                  style: const TextStyle(
                                    color: AppColors.primaryGold,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Corporate Fleet Affiliation Card
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
                          Icon(Icons.corporate_fare, color: AppColors.primaryGold, size: 16),
                          SizedBox(width: 7),
                          Text(
                            'EMPLOYING LOGISTICS FLEET',
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACCREDITED',
                          style: TextStyle(color: AppColors.primaryGold, fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fleetName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        Icon(Icons.info_outline, size: 15, color: AppColors.textMuted),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Corporate Remuneration Model: Delivery commissions, bonuses, and driver salaries are disbursed directly by your logistics company. Couriers do not require platform wallets.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Official Courier Payout Bank Account Card (Read-Only under Policy L-20)
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
                          Icon(Icons.account_balance, color: AppColors.primaryGold, size: 16),
                          SizedBox(width: 7),
                          Text(
                            'OFFICIAL PAYOUT BANK ACCOUNT',
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
                            Text(
                              'LOCKED',
                              style: TextStyle(color: AppColors.primaryGold, fontSize: 9, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (rider?.hasBankDetails == true) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bank Institution', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        Text(
                          rider!.bankName!,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('NUBAN Account Number', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        Text(
                          rider.accountNumber!,
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
                        const Text('Account Legal Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                        Flexible(
                          child: Text(
                            rider.accountName ?? '',
                            style: const TextStyle(color: AppColors.dispatchEmerald, fontSize: 12.5, fontWeight: FontWeight.w800),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        'Payout account details are pending Super Admin configuration.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11.5, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
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
                        Icon(Icons.shield_outlined, size: 14, color: AppColors.dispatchEmerald),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Account Security: For fraud prevention, couriers cannot edit payout details directly. All payout accounts are verified and registered by Platform Super Admin during onboarding.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Fleet Remuneration & Payroll Action Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.35), width: 1.0),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RiderEarningsScreen()),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, color: AppColors.primaryGold, size: 22),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fleet Remuneration & Settlement',
                                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13.5),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'View salary model, commission audit & shift statements',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: AppColors.primaryGold, size: 13),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Dispatch Alerts & Push Notifications Tile
            Consumer<RiderNotificationProvider>(
              builder: (context, notifProv, _) {
                final unread = notifProv.unreadCount;
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: unread > 0 ? AppColors.primaryGold.withOpacity(0.4) : AppColors.surfaceBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RiderNotificationsScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_active_outlined,
                              color: unread > 0 ? AppColors.primaryGold : AppColors.textSecondary,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Dispatch Alerts & Push Feed',
                                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13.5),
                                      ),
                                      if (unread > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.urgentRed,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            '$unread New',
                                            style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Manage FCM device link & view mission dispatch logs',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 13),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // Assigned Vehicle & Equipment
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
                  const Text(
                    'DISPATCH EQUIPMENT & CORRIDOR',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildProfileRow(Icons.two_wheeler, 'Vehicle Type', vehicleType),
                  const Divider(color: AppColors.surfaceBorder, height: 18),
                  _buildProfileRow(Icons.confirmation_number, 'Plate Number', licensePlate),
                  const Divider(color: AppColors.surfaceBorder, height: 18),
                  _buildProfileRow(Icons.phone, 'Contact Mobile', riderPhone),
                  const Divider(color: AppColors.surfaceBorder, height: 18),
                  _buildProfileRow(Icons.location_on, 'Assigned Corridor', corridor),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Duty Toggle Quick Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: dash.isDutyOnline ? AppColors.dispatchEmerald.withOpacity(0.35) : AppColors.surfaceBorder,
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dash.isDutyOnline ? AppColors.dispatchEmerald : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dash.isDutyOnline ? 'Shift Status: ONLINE (On Radar)' : 'Shift Status: OFFLINE (Standby)',
                        style: TextStyle(
                          color: dash.isDutyOnline ? AppColors.dispatchEmerald : AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: dash.isDutyOnline,
                      activeColor: AppColors.dispatchEmerald,
                      activeTrackColor: AppColors.dispatchEmerald.withOpacity(0.25),
                      inactiveThumbColor: AppColors.textMuted,
                      inactiveTrackColor: AppColors.surfaceElevated,
                      onChanged: (_) => dash.toggleDuty(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Secure Sign Out
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const RiderLoginScreen()),
                      (r) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Sign Out of Dispatch Terminal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.urgentRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
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
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }
}
