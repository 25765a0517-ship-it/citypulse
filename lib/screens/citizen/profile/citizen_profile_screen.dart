import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/common/app_button.dart';

class CitizenProfileScreen extends ConsumerWidget {
  const CitizenProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final complaintState = ref.watch(complaintProvider);

    final myComplaints = complaintState.allComplaints.where((c) => c.citizenId == (user?.uid ?? 'citizen_101')).toList();
    final inProgress = myComplaints.where((c) => c.status == 'inProgress' || c.status == 'assigned').length;
    final resolved = myComplaints.where((c) => c.status == 'resolved').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Citizen Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/citizen/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar & Name Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.primaryContainer,
                    backgroundImage: const AssetImage(AppConstants.citizenAvatarAsset),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Citizen Alex',
                    style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'citizen@citypulse.gov',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      user?.ward ?? 'Ward 4 • Downtown North',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSecondaryFixedVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: _statBox(
                    label: 'Reports Filed',
                    value: myComplaints.length.toString(),
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statBox(
                    label: 'In Progress',
                    value: inProgress.toString(),
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statBox(
                    label: 'Resolved',
                    value: resolved.toString(),
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Settings & Actions Menu
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Column(
                children: [
                  _menuTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    subtitle: 'Update phone number and neighborhood ward',
                    onTap: () => context.push('/citizen/edit-profile'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _menuTile(
                    icon: Icons.notifications_none,
                    title: 'Notification Preferences',
                    subtitle: 'Control SMS and in-app alerts',
                    onTap: () => context.push('/citizen/settings'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _menuTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy & Security',
                    subtitle: 'Role verification and public map visibility',
                    onTap: () => context.push('/citizen/settings'),
                  ),
                  const Divider(height: 1, indent: 56),
                  _menuTile(
                    icon: Icons.help_outline,
                    title: 'Help & Municipal Support',
                    subtitle: 'City hotline: 311 or citypulse-support@gov.city',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Municipal 311 helpline: Open 24/7')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            AppButton(
              label: 'End Session (Sign Out)',
              icon: Icons.logout,
              variant: AppButtonVariant.outline,
              onPressed: () => _confirmLogout(context, ref),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statBox({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.secondary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
      onTap: onTap,
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out of CityPulse?'),
        content: const Text('Are you sure you want to end your civic session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/auth/login');
              }
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
