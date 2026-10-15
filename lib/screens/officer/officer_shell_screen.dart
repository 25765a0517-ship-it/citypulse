import 'package:flutter/material.dart';
import '../../../widgets/navigation/primary_bottom_navigation.dart';
import 'dashboard/officer_dashboard_screen.dart';
import 'assigned/assigned_complaints_screen.dart';
import 'map/officer_map_screen.dart';
import 'notifications/officer_notifications_screen.dart';
import 'profile/officer_profile_screen.dart';

class OfficerShellScreen extends StatefulWidget {
  final int initialTab;

  const OfficerShellScreen({super.key, this.initialTab = 0});

  @override
  State<OfficerShellScreen> createState() => _OfficerShellScreenState();
}

class _OfficerShellScreenState extends State<OfficerShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      OfficerDashboardScreen(),
      AssignedComplaintsScreen(),
      OfficerMapScreen(),
      OfficerNotificationsScreen(),
      OfficerProfileScreen(),
    ];

    final navItems = const [
      NavigationItem(
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
      ),
      NavigationItem(
        label: 'Assigned',
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment,
      ),
      NavigationItem(
        label: 'Tactical Map',
        icon: Icons.navigation_outlined,
        activeIcon: Icons.navigation,
      ),
      NavigationItem(
        label: 'Alerts',
        icon: Icons.notifications_none,
        activeIcon: Icons.notifications,
      ),
      NavigationItem(
        label: 'Profile',
        icon: Icons.badge_outlined,
        activeIcon: Icons.badge,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: PrimaryBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: navItems,
      ),
    );
  }
}
