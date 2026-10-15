import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/user_model.dart';
import '../../../providers/department_provider.dart';
import '../../../widgets/common/ui_states.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personnel & User Hub'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.secondary,
          labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Citizens'),
            Tab(text: 'Officers'),
            Tab(text: 'Admins'),
          ],
        ),
      ),
      body: usersAsync.when(
        loading: () => const LoadingWidget(message: 'Loading user directory...'),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (allUsers) {
          final citizens = allUsers.where((u) => u.role == UserRole.citizen).toList();
          final officers = allUsers.where((u) => u.role == UserRole.officer).toList();
          final admins = allUsers.where((u) => u.role == UserRole.admin).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _userList(citizens),
              _userList(officers),
              _userList(admins),
            ],
          );
        },
      ),
    );
  }

  Widget _userList(List<UserModel> users) {
    if (users.isEmpty) {
      return const EmptyState(title: 'No Users', message: 'No users found in this role category.', icon: Icons.people_outline);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final u = users[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _roleColor(u.role).withValues(alpha: 0.15),
              child: Text(u.name.isNotEmpty ? u.name[0] : 'U', style: TextStyle(color: _roleColor(u.role), fontWeight: FontWeight.bold)),
            ),
            title: Text(u.name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
            subtitle: Text('${u.email} • ${u.ward ?? 'Downtown'}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _roleColor(u.role).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                u.role.name.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(color: _roleColor(u.role), fontWeight: FontWeight.w700),
              ),
            ),
            onTap: () => context.push('/admin/user/${u.uid}'),
          ),
        );
      },
    );
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.officer:
        return AppColors.warning;
      case UserRole.citizen:
        return AppColors.secondary;
    }
  }
}
