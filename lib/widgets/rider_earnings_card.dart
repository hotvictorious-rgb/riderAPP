import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_formatter.dart';

class RiderEarningsCard extends StatelessWidget {
  final double walletBalance;
  final double todayEarnings;
  final int completedTrips;
  final VoidCallback onWithdraw;

  const RiderEarningsCard({
    super.key,
    required this.walletBalance,
    required this.todayEarnings,
    required this.completedTrips,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E0E45), Color(0xFF100726)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryPurple.withOpacity(0.4), width: 1.5),
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.richGold.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 12, color: AppColors.richGold),
                    SizedBox(width: 4),
                    Text(
                      'RIDER DISPATCH WALLET',
                      style: TextStyle(color: AppColors.richGold, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              Text(
                '$completedTrips Trips Completed',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Available Payout Balance', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(walletBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Deliveries", style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(todayEarnings),
                        style: const TextStyle(color: AppColors.dispatchEmerald, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: onWithdraw,
                icon: const Icon(Icons.arrow_upward, size: 14),
                label: const Text('Withdraw'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}