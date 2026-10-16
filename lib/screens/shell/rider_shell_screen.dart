import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/rider_delivery_provider.dart';
import '../dashboard/rider_dashboard_screen.dart';
import '../deliveries/rider_deliveries_screen.dart';
import '../returns/rider_returns_screen.dart';
import '../history/rider_history_screen.dart';
import '../profile/rider_profile_screen.dart';

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
    RiderReturnsScreen(),
    RiderHistoryScreen(),
    RiderProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final deliv = Provider.of<RiderDeliveryProvider>(context);
    final activeMissionsCount = deliv.activeDeliveries.length;
    final activeReturnsCount = deliv.activeReturns.length;

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
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Radar'),
            BottomNavigationBarItem(
              icon: activeMissionsCount > 0
                  ? Badge.count(
                      count: activeMissionsCount,
                      backgroundColor: AppColors.primaryPurple,
                      textColor: Colors.white,
                      child: const Icon(Icons.local_shipping),
                    )
                  : const Icon(Icons.local_shipping),
              label: 'Missions',
            ),
            BottomNavigationBarItem(
              icon: activeReturnsCount > 0
                  ? Badge.count(
                      count: activeReturnsCount,
                      backgroundColor: AppColors.urgentRed,
                      textColor: Colors.white,
                      child: const Icon(Icons.assignment_return),
                    )
                  : const Icon(Icons.assignment_return),
              label: 'Returns',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Trip Log'),
            const BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), label: 'Fleet Profile'),
          ],
        ),
      ),
    );
  }
}