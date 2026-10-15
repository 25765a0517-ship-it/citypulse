import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/complaint_provider.dart';

class ResolutionDetailsScreen extends ConsumerWidget {
  final String complaintId;

  const ResolutionDetailsScreen({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintState = ref.watch(complaintProvider);
    final complaint = complaintState.allComplaints.firstWhere(
      (c) => c.id == complaintId,
      orElse: () => complaintState.allComplaints.first,
    );

    final beforePhoto = complaint.imageUrls.isNotEmpty
        ? complaint.imageUrls.first
        : AppConstants.potholeAsset;
    final afterPhoto = complaint.resolutionImageUrls.isNotEmpty
        ? complaint.resolutionImageUrls.first
        : AppConstants.repairedRoadAsset;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Resolution Evidence'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verified Seal Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.statusResolvedBg,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.statusResolved,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Municipal Verification Seal',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.statusResolved,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Signed off by Inspector Marcus Vance • DOTI Field Ops',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Side-by-Side Comparison
            Text(
              'Before & After Inspection',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'BEFORE REPORT',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.onErrorContainer),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Image.asset(
                          beforePhoto,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 140,
                            color: AppColors.surfaceContainer,
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: AppColors.statusResolvedBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'AFTER REPAIR',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.statusResolved),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Image.asset(
                          afterPhoto,
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            height: 140,
                            color: AppColors.surfaceContainer,
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Resolution Dossier Details
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
                    'Work Procedure Details',
                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    complaint.resolutionNotes ??
                        'Standard asphalt cold-patch compaction procedure executed. Base subsurface inspected and sealed to prevent stormwater seepage.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completion Timestamp',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
                      ),
                      Text(
                        Formatters.formatDateTime(complaint.resolvedAt ?? DateTime.now()),
                        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SLA Turnaround',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
                      ),
                      Text(
                        '3h 15m (Within Target)',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
