import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/complaint/complaint_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintState = ref.watch(complaintProvider);
    final all = complaintState.allComplaints;

    final totalCount = all.length;
    final pendingCount = all.where((c) => c.status == 'submitted' || c.status == 'verified').length;
    final inProgressCount = all.where((c) => c.status == 'assigned' || c.status == 'inProgress').length;
    final resolvedCount = all.where((c) => c.status == 'resolved').length;

    final criticalCount = all.where((c) => c.priority == 'CRITICAL').length;


    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(AppConstants.logoAsset, height: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('CityPulse Admin', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text('LIVE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onTertiaryContainer, fontSize: 9)),
                    ),
                  ],
                ),
                Text('Municipal Command Center', style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Telemetry Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Metropolitan Operations Feed',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text('Wards 1–7 Online', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Real-time municipal triage, department dispatching, and field unit tracking.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2x2 Summary KPI Grid
            Row(
              children: [
                Expanded(
                  child: _kpi(
                    title: 'Total Filed',
                    value: totalCount.toString(),
                    trend: '+12% vs last week',
                    icon: Icons.inbox_outlined,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _kpi(
                    title: 'Pending Triage',
                    value: pendingCount.toString(),
                    trend: '$criticalCount critical',
                    icon: Icons.assignment_late_outlined,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _kpi(
                    title: 'In Progress',
                    value: inProgressCount.toString(),
                    trend: 'Active road crews',
                    icon: Icons.engineering_outlined,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _kpi(
                    title: 'Resolved',
                    value: resolvedCount.toString(),
                    trend: 'SLA 94.2%',
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Shortcuts Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _actionChip(
                    icon: Icons.campaign_outlined,
                    label: 'Broadcast Advisory',
                    color: AppColors.secondary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Municipal Advisory Broadcast sent to Ward 4')),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _actionChip(
                    icon: Icons.alt_route,
                    label: 'Unassigned Queue ($pendingCount)',
                    color: AppColors.error,
                    onTap: () => context.push('/admin/complaints'),
                  ),
                  const SizedBox(width: 8),
                  _actionChip(
                    icon: Icons.analytics_outlined,
                    label: 'Analytics Hub',
                    color: AppColors.onSurfaceVariant,
                    onTap: () => context.push('/admin/analytics'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Distribution
            SectionHeader(
              title: 'Complaints by Category',
              subtitle: 'Active volume breakdown',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                children: AppConstants.categories.map((cat) {
                  final catCount = all.where((c) => c.category.toLowerCase() == cat.toLowerCase()).length;
                  final percentage = totalCount > 0 ? (catCount / totalCount) : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(cat, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                            Text('$catCount reports (${(percentage * 100).toStringAsFixed(0)}%)', style: AppTextStyles.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: AppColors.surfaceContainer,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 22),

            // Recent Complaints Section
            SectionHeader(
              title: 'Recent Reports',
              subtitle: 'Latest incoming citizen reports requiring assignment',
              trailing: TextButton(
                onPressed: () => context.push('/admin/complaints'),
                child: Text('Manage All →', style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),

            ...all.take(3).map((complaint) {
              return ComplaintCard(
                complaint: complaint,
                onTap: () => context.push('/admin/complaint/${complaint.id}'),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _kpi({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(trend, style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.outline)),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.labelMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
