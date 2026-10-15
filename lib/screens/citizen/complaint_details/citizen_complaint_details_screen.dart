import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/complaint_history_model.dart';
import '../../../models/complaint_model.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/priority_badge.dart';
import '../../../widgets/common/status_badge.dart';
import '../../../widgets/complaint/timeline_widget.dart';

class CitizenComplaintDetailsScreen extends ConsumerStatefulWidget {
  final String complaintId;

  const CitizenComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  ConsumerState<CitizenComplaintDetailsScreen> createState() => _CitizenComplaintDetailsScreenState();
}

class _CitizenComplaintDetailsScreenState extends ConsumerState<CitizenComplaintDetailsScreen> {
  List<ComplaintHistoryModel> _timeline = [];
  bool _loadingTimeline = true;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    final list = await ref.read(complaintProvider.notifier).getTimeline(widget.complaintId);
    if (mounted) {
      setState(() {
        _timeline = list;
        _loadingTimeline = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);
    final complaint = complaintState.allComplaints.firstWhere(
      (c) => c.id == widget.complaintId,
      orElse: () => ComplaintModel(
        id: widget.complaintId,
        citizenId: 'citizen_101',
        citizenName: 'Citizen Alex',
        category: 'Pothole',
        description: 'Details for ticket #${widget.complaintId}',
        latitude: 12.9716,
        longitude: 77.5946,
        address: 'Ward 4 • Downtown North',
      ),
    );

    final isResolved = complaint.status.toLowerCase() == 'resolved';
    final photo = complaint.imageUrls.isNotEmpty ? complaint.imageUrls.first : 'assets/images/pothole.png';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(Formatters.formatComplaintId(complaint.id)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share link generated for Ticket #${complaint.id}')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              child: Container(
                width: double.infinity,
                height: 200,
                color: AppColors.surfaceContainer,
                child: Image.asset(
                  photo,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(Icons.image, size: 64, color: AppColors.outlineVariant),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row: Status & Priority
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: complaint.status),
                PriorityBadge(priority: complaint.priority),
              ],
            ),
            const SizedBox(height: 12),

            // Category & Time
            Text(
              complaint.category,
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppColors.outline),
                const SizedBox(width: 4),
                Text(
                  'Reported on ${Formatters.formatDateTime(complaint.createdAt)}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Problem Description',
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

            // Location Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on, color: AppColors.secondary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        Text(
                          complaint.address,
                          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Department & Officer Assignment Info
            if (complaint.departmentName != null || complaint.officerName != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
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
                      child: const Icon(Icons.engineering, color: AppColors.secondary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint.departmentName ?? 'Municipal Operations',
                            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            complaint.officerName != null
                                ? 'Assigned Field Officer: ${complaint.officerName}'
                                : 'Assigned to department dispatch queue',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // If Resolved -> Show Resolution Evidence CTA
            if (isResolved) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.statusResolvedBg,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.statusResolved.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.statusResolved, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Officially Resolved by Field Unit',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.statusResolved,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      complaint.resolutionNotes ?? 'Repair verified and completed by city operations.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'View Before/After Resolution Details',
                      variant: AppButtonVariant.primary,
                      height: 40,
                      onPressed: () {
                        context.push('/citizen/complaint/${complaint.id}/resolution');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Live Timeline Section
            Text(
              'Resolution Milestones',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (_loadingTimeline)
              const Center(child: CircularProgressIndicator())
            else
              ComplaintTimelineWidget(
                historyItems: _timeline,
                currentStatus: complaint.status,
              ),
          ],
        ),
      ),
    );
  }
}
