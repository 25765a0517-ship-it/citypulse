import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/app_button.dart';

class OfficerProfileScreen extends ConsumerWidget {
  const OfficerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Officer Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primaryContainer,
                    backgroundImage: const AssetImage(AppConstants.officerAvatarAsset),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Marcus Vance',
                    style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Badge #4412 • Field Unit #14',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Department of Transportation & Infrastructure (DOTI)',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Column(
                      children: [
                        Text('14', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w800)),
                        Text('Active Queue', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Column(
                      children: [
                        Text('48', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.w800)),
                        Text('Resolved MTD', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            AppButton(
              label: 'Sign Out (End Shift)',
              icon: Icons.logout,
              variant: AppButtonVariant.outline,
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/auth/login');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
