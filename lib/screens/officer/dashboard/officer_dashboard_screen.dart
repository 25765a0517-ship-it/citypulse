import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/common/section_header.dart';
import '../../../widgets/complaint/complaint_card.dart';

class OfficerDashboardScreen extends ConsumerStatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  ConsumerState<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends ConsumerState<OfficerDashboardScreen> {
  String _dutyStatus = 'on-duty'; // 'on-duty', 'en-route', 'on-break'

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final complaintState = ref.watch(complaintProvider);

    final assignedToMe = complaintState.allComplaints.where((c) {
      return c.officerId == (user?.uid ?? 'officer_202') || c.status == 'assigned' || c.status == 'inProgress';
    }).toList();

    final criticalCount = assignedToMe.where((c) => c.priority == 'CRITICAL' || c.priority == 'HIGH').length;
    final inProgressCount = assignedToMe.where((c) => c.status == 'inProgress').length;
    final resolvedCount = assignedToMe.where((c) => c.status == 'resolved').length;

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
                Text(
                  'CityPulse Officer',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  'DOTI Field Unit • Officer Dashboard',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => context.push('/officer/alerts'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Officer Hero & Status Control Card
            Container(
              padding: const EdgeInsets.all(16),
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
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryContainer,
                            backgroundImage: const AssetImage(AppConstants.officerAvatarAsset),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: _dutyStatus == 'on-duty' ? AppColors.tertiaryFixedDim : AppColors.secondary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DOTI WARD 4 FIELD UNIT',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              user?.name ?? 'Marcus Vance',
                              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Badge #4412 • Mobile Asphalt Crew',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Duty Status Toggle Pill
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        _statusPill('On Duty', 'on-duty', AppColors.tertiaryFixedDim),
                        _statusPill('En Route', 'en-route', AppColors.secondary),
                        _statusPill('On Break', 'on-break', AppColors.outline),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Transponder Telemetry Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Unit #14 • Mobile Utility',
                            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixed,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '🛰️ GPS ±1.5m',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.onSecondaryFixedVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.58,
                    backgroundColor: AppColors.surfaceContainer,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shift 07:00 – 15:30', style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.outline)),
                      Text('4h 45m elapsed (58%)', style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Operational Statistics Bento Grid
            SectionHeader(
              title: 'Shift Overview',
              subtitle: 'Ward 4 Real-time Field Feed',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    title: 'Assigned',
                    value: assignedToMe.length.toString(),
                    subtitle: 'Active queue',
                    icon: Icons.assignment_outlined,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _kpiCard(
                    title: 'High Priority',
                    value: criticalCount.toString().padLeft(2, '0'),
                    subtitle: 'Urgent action',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.error,
                    bgColor: AppColors.errorContainer.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _kpiCard(
                    title: 'In Progress',
                    value: inProgressCount.toString(),
                    subtitle: 'On-site repairs',
                    icon: Icons.build_circle_outlined,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _kpiCard(
                    title: 'Resolved Today',
                    value: resolvedCount.toString(),
                    subtitle: 'Verified closed',
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Needs Attention Section
            SectionHeader(
              title: 'Needs Urgent Attention',
              subtitle: 'Top high-severity dispatch tickets',
              trailing: TextButton(
                onPressed: () => context.push('/officer/assigned'),
                child: Text('View All (${assignedToMe.length}) →', style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 8),

            ...assignedToMe.take(3).map((complaint) {
              return ComplaintCard(
                complaint: complaint,
                showOfficerDetails: true,
                onTap: () => context.push('/officer/complaint/${complaint.id}'),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String label, String id, Color dotColor) {
    final isSelected = _dutyStatus == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _dutyStatus = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
          Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }
}
