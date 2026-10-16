import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../dashboard/rider_dashboard_screen.dart';
import '../deliveries/rider_deliveries_screen.dart';
import '../history/rider_history_screen.dart';
import '../wallet/rider_wallet_screen.dart';

class RiderShellScreen extends StatefulWidget {
  const RiderShellScreen({super.key});

  @override
  State<RiderShellScreen> createState() => _RiderShellScreenState();
}

class _RiderShellScreenState extends State<RiderShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    RiderDashboardScreen(),
    RiderDeliveriesScreen(),
    RiderHistoryScreen(),
    RiderWalletScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.obsidianCard,
          border: Border(top: BorderSide(color: AppColors.obsidianBorder, width: 1.2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.richGold,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Dispatch'),
            BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Active Trips'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          ],
        ),
      ),
    );
  }
}