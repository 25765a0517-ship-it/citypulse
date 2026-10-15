import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/common/ui_states.dart';

class OfficerNotificationsScreen extends ConsumerWidget {
  const OfficerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dispatch Alerts & Notifications'),
      ),
      body: notifsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading dispatch feed...'),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              title: 'No Active Dispatch Alerts',
              message: 'Your field queue is up to date.',
              icon: Icons.notifications_none,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final notif = list[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emergency_outlined, color: AppColors.secondary),
                  ),
                  title: Text(notif.title, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text(notif.message, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  onTap: () {
                    if (notif.complaintId != null) {
                      context.push('/officer/complaint/${notif.complaintId}');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
