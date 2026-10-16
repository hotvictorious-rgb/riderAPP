import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_auth_provider.dart';
import '../auth/rider_login_screen.dart';

class RiderProfileScreen extends StatelessWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<RiderAuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.obsidianBg,
      appBar: AppBar(title: const Text('COURIER SETTINGS')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.obsidianCard, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const CircleAvatar(backgroundColor: AppColors.primaryPurple, child: Icon(Icons.two_wheeler, color: Colors.white)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.currentRider?.name ?? 'Musa Haruna', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(auth.currentRider?.vehicleType ?? 'Motorbike Express Courier', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text(auth.currentRider?.fleetCompany ?? 'Speedy Parcel Express', style: const TextStyle(color: AppColors.richGold, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out of Dispatch'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.urgentRed,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}