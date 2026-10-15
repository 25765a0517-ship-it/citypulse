import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/priority_badge.dart';
import '../../../widgets/common/status_badge.dart';

class OfficerComplaintDetailsScreen extends ConsumerStatefulWidget {
  final String complaintId;

  const OfficerComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  ConsumerState<OfficerComplaintDetailsScreen> createState() => _OfficerComplaintDetailsScreenState();
}

class _OfficerComplaintDetailsScreenState extends ConsumerState<OfficerComplaintDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);
    final authState = ref.watch(authProvider);
    final officerName = authState.user?.name ?? 'Marcus Vance';

    final complaint = complaintState.allComplaints.firstWhere(
      (c) => c.id == widget.complaintId,
      orElse: () => complaintState.allComplaints.first,
    );

    final photo = complaint.imageUrls.isNotEmpty ? complaint.imageUrls.first : AppConstants.potholeAsset;
    final status = complaint.status.toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Work Order #${complaint.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation_outlined),
            onPressed: () => context.push('/officer/map?complaintId=${complaint.id}'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Work Order Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              child: Image.asset(
                photo,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(height: 200, color: AppColors.surfaceContainer),
              ),
            ),
            const SizedBox(height: 16),

            // Telemetry Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: complaint.status),
                PriorityBadge(priority: complaint.priority),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              complaint.category,
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Reported by ${complaint.citizenName} • ${Formatters.formatDateTime(complaint.createdAt)}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: 16),

            // Citizen Problem Dossier
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hazard Description',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    complaint.description,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Site Location Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Site Coordinates', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                        Text(complaint.address, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.directions, color: AppColors.secondary),
                    onPressed: () => context.push('/officer/map?complaintId=${complaint.id}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tactical Actions Based On Operational State
            Text(
              'Field Unit Actions',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            if (status == 'assigned') ...[
              AppButton(
                label: 'Accept Work Order',
                icon: Icons.check_circle_outline,
                onPressed: () async {
                  await ref.read(complaintProvider.notifier).updateStatus(
                        complaintId: complaint.id,
                        status: 'inProgress',
                        changedBy: officerName,
                        note: 'Officer $officerName accepted assignment and started work procedure.',
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Accepted task! Unit #14 en route.')),
                    );
                  }
                },
              ),
            ] else if (status == 'inprogress') ...[
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Navigate to Site',
                      icon: Icons.navigation_outlined,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.push('/officer/map?complaintId=${complaint.id}'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: 'Complete Resolution',
                      icon: Icons.camera_alt_outlined,
                      onPressed: () => context.push('/officer/resolve/${complaint.id}'),
                    ),
                  ),
                ],
              ),
            ] else if (status == 'resolved') ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.statusResolvedBg,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppColors.statusResolved),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Work order resolved. Verified before & after photos logged.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.statusResolved),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'View Resolution Dossier',
                variant: AppButtonVariant.outline,
                onPressed: () => context.push('/citizen/complaint/${complaint.id}/resolution'),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
