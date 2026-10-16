import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/rider_auth_provider.dart';
import '../../providers/rider_dashboard_provider.dart';

class RiderWalletScreen extends StatelessWidget {
  const RiderWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dash = Provider.of<RiderDashboardProvider>(context);
    final auth = Provider.of<RiderAuthProvider>(context);
    final balance = dash.dashboardMetrics?.walletBalance ?? 14500.00;
    final riderName = dash.profile?.name ?? auth.currentRider?.name ?? 'MUSA HARUNA';
    final fleetName = dash.profile?.fleetCompany ?? auth.currentRider?.fleetCompany ?? 'Speedy Parcel Express';

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      appBar: AppBar(title: const Text('RIDER WALLET & PAYOUT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Affiliated Logistics Company & Courier Identity Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.obsidianCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryPurple.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.business, color: AppColors.primaryPurple, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AFFILIATED LOGISTICS COMPANY',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fleetName,
                          style: const TextStyle(color: AppColors.richGold, fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Certified Courier: $riderName',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Disbursement Account Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.obsidianCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.richGold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('LINKED DISBURSEMENT BANK', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Zenith Bank PLC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  Text('******4756 (${riderName.toUpperCase()})', style: const TextStyle(color: AppColors.richGold, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.dispatchAmber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.dispatchAmber.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield, color: AppColors.dispatchAmber, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '48-Hour Bank Cooldown Anti-Theft Protection Active.',
                            style: TextStyle(color: AppColors.dispatchAmber, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Instant withdrawal request for ${CurrencyFormatter.format(balance)} submitted.')),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.dispatchEmerald,
              ),
              child: Text('Request Payout (${CurrencyFormatter.format(balance)})'),
            ),
          ],
        ),
      ),
    );
  }
}