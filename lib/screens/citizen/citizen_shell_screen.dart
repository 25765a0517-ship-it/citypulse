import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/navigation/primary_bottom_navigation.dart';
import 'home/citizen_home_screen.dart';
import 'map/citizen_map_screen.dart';
import 'reports/my_reports_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/citizen_profile_screen.dart';

class CitizenShellScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const CitizenShellScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<CitizenShellScreen> createState() => _CitizenShellScreenState();
}

class _CitizenShellScreenState extends ConsumerState<CitizenShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    final screens = const [
      CitizenHomeScreen(),
      CitizenMapScreen(),
      MyReportsScreen(),
      CitizenNotificationsScreen(),
      CitizenProfileScreen(),
    ];

    final navItems = [
      const NavigationItem(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      const NavigationItem(
        label: 'Nearby Map',
        icon: Icons.map_outlined,
        activeIcon: Icons.map,
      ),
      const NavigationItem(
        label: 'My Reports',
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment,
      ),
      NavigationItem(
        label: 'Alerts',
        icon: Icons.notifications_none,
        activeIcon: Icons.notifications,
        badgeCount: unreadCount,
      ),
      const NavigationItem(
        label: 'Profile',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
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
