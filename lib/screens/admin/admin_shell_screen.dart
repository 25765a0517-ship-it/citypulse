import 'package:flutter/material.dart';
import '../../../widgets/navigation/primary_bottom_navigation.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'complaints/all_complaints_screen.dart';
import 'departments/departments_screen.dart';
import 'users/user_management_screen.dart';
import 'analytics/city_analytics_screen.dart';

class AdminShellScreen extends StatefulWidget {
  final int initialTab;

  const AdminShellScreen({super.key, this.initialTab = 0});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      AdminDashboardScreen(),
      AllComplaintsScreen(),
      DepartmentsScreen(),
      UserManagementScreen(),
      CityAnalyticsScreen(),
    ];

    final navItems = const [
      NavigationItem(
        label: 'Dashboard',
        icon: Icons.space_dashboard_outlined,
        activeIcon: Icons.space_dashboard,
      ),
      NavigationItem(
        label: 'Complaints',
        icon: Icons.inbox_outlined,
        activeIcon: Icons.inbox,
      ),
      NavigationItem(
        label: 'Departments',
        icon: Icons.business_outlined,
        activeIcon: Icons.business,
      ),
      NavigationItem(
        label: 'Personnel',
        icon: Icons.people_outline,
        activeIcon: Icons.people,
      ),
      NavigationItem(
        label: 'Analytics',
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics,
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
