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
      backgroundColor: AppColors.obsidianBg,
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E0E45), Color(0xFF13092A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryPurple.withOpacity(0.4), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ],
                    child: const Icon(Icons.two_wheeler, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          riderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          riderEmail,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.dispatchEmerald.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.dispatchEmerald.withOpacity(0.4)),
                              ),
                              child: const Text(
                                'ACTIVE COURIER',
                                style: TextStyle(
                                  color: AppColors.dispatchEmerald,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.richGold, size: 13),
                                const SizedBox(width: 3),
                                Text(
                                  '${(rider?.rating ?? 5.0).toStringAsFixed(1)} Rating',
                                  style: const TextStyle(
                                    color: AppColors.richGold,
                                    fontSize: 11,
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
            const SizedBox(height: 16),

            // Corporate Fleet Affiliation Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.obsidianCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.richGold.withOpacity(0.3), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.corporate_fare, color: AppColors.richGold, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'EMPLOYING LOGISTICS FLEET',
                            style: TextStyle(
                              color: AppColors.richGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.richGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACCREDITED',
                          style: TextStyle(color: AppColors.richGold, fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fleetName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
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
                        Icon(Icons.info_outline, size: 15, color: AppColors.textMuted),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Corporate Remuneration Model: Delivery commissions, bonuses, and driver salaries are disbursed directly by your logistics company. Couriers do not require platform wallets.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fleet Remuneration & Payroll Action Button
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RiderEarningsScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A1550), Color(0xFF160A30)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.richGold.withOpacity(0.4), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.richGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.richGold.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.receipt_long, color: AppColors.richGold, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fleet Remuneration & Settlement',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'View salary model, commission audit & shift statements',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: AppColors.richGold, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Dispatch Alerts & Push Notifications Tile
            Consumer<RiderNotificationProvider>(
              builder: (context, notifProv, _) {
                final unread = notifProv.unreadCount;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RiderNotificationsScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.obsidianCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: unread > 0 ? AppColors.richGold.withOpacity(0.5) : AppColors.obsidianBorder,
                        width: unread > 0 ? 1.2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: unread > 0 ? AppColors.richGold.withOpacity(0.15) : Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: unread > 0 ? AppColors.richGold.withOpacity(0.3) : Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            color: unread > 0 ? AppColors.richGold : AppColors.textSecondary,
                            size: 22,
                          ),
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
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
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
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
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
                        const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Assigned Vehicle & Equipment
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.obsidianCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.obsidianBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DISPATCH EQUIPMENT & CORRIDOR',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildProfileRow(Icons.two_wheeler, 'Vehicle Type', vehicleType),
                  const Divider(color: AppColors.obsidianBorder, height: 18),
                  _buildProfileRow(Icons.confirmation_number, 'Plate Number', licensePlate),
                  const Divider(color: AppColors.obsidianBorder, height: 18),
                  _buildProfileRow(Icons.phone, 'Contact Mobile', riderPhone),
                  const Divider(color: AppColors.obsidianBorder, height: 18),
                  _buildProfileRow(Icons.location_on, 'Assigned Corridor', corridor),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Duty Toggle Quick Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.obsidianCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: dash.isDutyOnline ? AppColors.dispatchEmerald.withOpacity(0.4) : AppColors.obsidianBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: dash.isDutyOnline ? AppColors.dispatchEmerald : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        dash.isDutyOnline ? 'Shift Status: ONLINE (On Radar)' : 'Shift Status: OFFLINE (Resting)',
                        style: TextStyle(
                          color: dash.isDutyOnline ? AppColors.dispatchEmerald : AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: dash.isDutyOnline,
                    activeColor: AppColors.dispatchEmerald,
                    onChanged: (_) => dash.toggleDuty(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Secure Sign Out
            ElevatedButton.icon(
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
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign Out of Dispatch Terminal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.urgentRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
        Icon(icon, size: 18, color: AppColors.primaryPurple),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }
}