import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/common/ui_states.dart';

class CitizenNotificationsScreen extends ConsumerWidget {
  const CitizenNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsStreamProvider);
    final user = ref.watch(authProvider).user;
    final userId = user?.uid ?? 'citizen_101';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationRepositoryProvider).markAllAsRead(userId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: Text(
              'Mark all read',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      ),
      body: notifsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading notifications...'),
        error: (err, _) => ErrorState(message: err.toString()),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              title: 'No new notifications',
              message: 'You are all caught up with municipal updates!',
              icon: Icons.notifications_none,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: notif.read ? AppColors.surfaceContainerLowest : AppColors.secondaryFixed.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: notif.read ? AppColors.surfaceContainerLow : AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notif.type),
                      size: 20,
                      color: notif.read ? AppColors.secondary : Colors.white,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: notif.read ? FontWeight.w600 : FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        Formatters.timeAgo(notif.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      notif.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  onTap: () {
                    ref.read(notificationRepositoryProvider).markAsRead(notif.id);
                    if (notif.complaintId != null) {
                      context.push('/citizen/complaint/${notif.complaintId}');
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

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'complaintSubmitted':
        return Icons.send;
      case 'complaintVerified':
        return Icons.verified;
      case 'officerAssigned':
        return Icons.assignment_ind;
      case 'workStarted':
        return Icons.build;
      case 'complaintResolved':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }
}
