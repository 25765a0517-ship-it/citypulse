import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/common/ui_states.dart';
import '../../../widgets/complaint/category_card.dart';
import '../../../widgets/complaint/complaint_card.dart';

class CitizenHomeScreen extends ConsumerWidget {
  const CitizenHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final complaintState = ref.watch(complaintProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    final user = authState.user;
    final userName = user?.name ?? 'Citizen Alex';
    final userWard = user?.ward ?? 'Ward 4 • Downtown North';

    final allComplaints = complaintState.allComplaints;
    final myComplaints = allComplaints.where((c) => c.citizenId == (user?.uid ?? 'citizen_101')).toList();
    final inProgressCount = allComplaints.where((c) => c.status == 'inProgress' || c.status == 'assigned').length;
    final resolvedCount = allComplaints.where((c) => c.status == 'resolved').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: () async {
            await ref.read(complaintProvider.notifier).loadComplaints();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Greeting & Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Good morning,',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(width: 4),
                            const Text('✨', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              userName,
                              style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryFixed,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified, size: 12, color: AppColors.onSecondaryFixedVariant),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Verified',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.onSecondaryFixedVariant,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 3),
                            Text(
                              userWard,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Notification Bell
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none, size: 26, color: AppColors.onSurface),
                              onPressed: () => context.push('/citizen/notifications'),
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text(
                                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Avatar
                        GestureDetector(
                          onTap: () => context.push('/citizen/profile'),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primaryContainer,
                            backgroundImage: const AssetImage(AppConstants.citizenAvatarAsset),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Hero Card: See a Problem?
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryContainer,
                        AppColors.inverseSurface,
                        AppColors.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.round3xl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.tertiaryFixedDim,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '📍 Auto-locating ward • GPS Active',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.inverseOnSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'See a problem?',
                        style: AppTextStyles.headlineLargeMobile.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Report civic infrastructure issues and help upgrade your neighborhood in seconds.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // CTA Button
                      Material(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: InkWell(
                          onTap: () => context.push('/citizen/report/step-1'),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add_a_photo, size: 18, color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '+ Report a Problem',
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Statistics Bento Row
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.assignment_outlined,
                        color: AppColors.secondary,
                        count: myComplaints.length.toString(),
                        title: 'My Reports',
                        subtitle: 'Submitted',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        icon: Icons.build_circle_outlined,
                        color: AppColors.warning,
                        count: inProgressCount.toString(),
                        title: 'In Progress',
                        subtitle: 'Under Repair',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                        count: resolvedCount.toString(),
                        title: 'Resolved',
                        subtitle: 'Verified Done',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Quick Categories Header
                SectionHeader(
                  title: 'Quick Categories',
                  subtitle: 'Select issue category to start a verified report',
                ),
                const SizedBox(height: 8),

                // 2x3 Category Grid
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.95,
                  children: AppConstants.categories.map((category) {
                    return CategoryCard(
                      title: category,
                      icon: CategoryCard.getIconForCategory(category),
                      isSelected: false,
                      onTap: () {
                        ref.read(complaintProvider.notifier).updateDraftCategory(category);
                        context.push('/citizen/report/step-1');
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Nearby Problems Preview Header
                SectionHeader(
                  title: 'Nearby Problems',
                  subtitle: 'Live verified hazards reported around Ward 4',
                  trailing: TextButton(
                    onPressed: () => context.push('/citizen/map'),
                    child: Text(
                      'View Map →',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Complaints List with Loading, Empty & Data states
                if (complaintState.isLoading)
                  const LoadingWidget(message: 'Loading nearby reports...')
                else if (allComplaints.isEmpty)
                  const EmptyState(
                    title: 'No complaints in this area',
                    message: 'Your neighborhood is running smoothly! Tap Report to file an issue.',
                    icon: Icons.check_circle_outline,
                  )
                else
                  ...allComplaints.take(4).map((complaint) {
                    return ComplaintCard(
                      complaint: complaint,
                      onTap: () => context.push('/citizen/complaint/${complaint.id}'),
                    );
                  }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color color,
    required String count,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
