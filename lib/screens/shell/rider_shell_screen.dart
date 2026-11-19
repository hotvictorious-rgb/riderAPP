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
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.surfaceBorder, width: 1.0),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primaryGold,
              unselectedItemColor: AppColors.textMuted,
              selectedFontSize: 11,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.2),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.radar_outlined, size: 22),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.radar, size: 22),
                  ),
                  label: 'Radar',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: activeMissionsCount > 0
                        ? Badge(
                            label: Text(
                              activeMissionsCount > 9 ? '9+' : '$activeMissionsCount',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9.5),
                            ),
                            backgroundColor: AppColors.primaryGold,
                            child: const Icon(Icons.local_shipping_outlined, size: 22),
                          )
                        : const Icon(Icons.local_shipping_outlined, size: 22),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: activeMissionsCount > 0
                        ? Badge(
                            label: Text(
                              activeMissionsCount > 9 ? '9+' : '$activeMissionsCount',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9.5),
                            ),
                            backgroundColor: AppColors.primaryGold,
                            child: const Icon(Icons.local_shipping, size: 22),
                          )
                        : const Icon(Icons.local_shipping, size: 22),
                  ),
                  label: 'Missions',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: activeReturnsCount > 0
                        ? Badge(
                            label: Text(
                              activeReturnsCount > 9 ? '9+' : '$activeReturnsCount',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9.5),
                            ),
                            backgroundColor: AppColors.urgentRed,
                            child: const Icon(Icons.assignment_return_outlined, size: 22),
                          )
                        : const Icon(Icons.assignment_return_outlined, size: 22),
                  ),
                  activeIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: activeReturnsCount > 0
                        ? Badge(
                            label: Text(
                              activeReturnsCount > 9 ? '9+' : '$activeReturnsCount',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 9.5),
                            ),
                            backgroundColor: AppColors.urgentRed,
                            child: const Icon(Icons.assignment_return, size: 22),
                          )
                        : const Icon(Icons.assignment_return, size: 22),
                  ),
                  label: 'Returns',
                ),
                const BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.history_outlined, size: 22),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.history, size: 22),
                  ),
                  label: 'Trip Log',
                ),
                const BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.badge_outlined, size: 22),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.badge, size: 22),
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
