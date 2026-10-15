import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/department_provider.dart';
import '../../../widgets/common/ui_states.dart';

class UserDetailsScreen extends ConsumerWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('User Record Dossier'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: usersAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (all) {
          final user = all.firstWhere((u) => u.uid == userId, orElse: () => all.first);

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.secondaryFixed,
                    child: Text(
                      user.name[0],
                      style: AppTextStyles.headlineLarge.copyWith(color: AppColors.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(user.name, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
                ),
                Center(
                  child: Text(user.email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Column(
                    children: [
                      _row('Role', user.role.name.toUpperCase()),
                      const Divider(height: 20),
                      _row('Phone', user.phone.isNotEmpty ? user.phone : 'Not provided'),
                      const Divider(height: 20),
                      _row('Ward Assignment', user.ward ?? 'Downtown Metro'),
                      const Divider(height: 20),
                      _row('Account Status', 'Active & Verified'),
                      const Divider(height: 20),
                      _row('Created', Formatters.formatDate(user.createdAt)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
        Text(value, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
