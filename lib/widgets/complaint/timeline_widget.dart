import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/complaint_history_model.dart';

class ComplaintTimelineWidget extends StatelessWidget {
  final List<ComplaintHistoryModel> historyItems;
  final String currentStatus;

  const ComplaintTimelineWidget({
    super.key,
    required this.historyItems,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (historyItems.isEmpty) {
      return Center(
        child: Text(
          'No history records available yet.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        final isLast = index == historyItems.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line & indicator
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isLast ? AppColors.secondary : AppColors.secondaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForStatus(item.status),
                    size: 16,
                    color: isLast ? AppColors.onSecondary : AppColors.secondary,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Timeline description
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getLabelForStatus(item.status),
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          Formatters.formatTime(item.timestamp),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.outline,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By ${item.changedBy}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return Icons.send;
      case 'verified':
        return Icons.verified;
      case 'assigned':
        return Icons.assignment_ind;
      case 'inprogress':
      case 'in_progress':
      case 'in progress':
        return Icons.build;
      case 'resolved':
        return Icons.check_circle;
      default:
        return Icons.circle;
    }
  }

  String _getLabelForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Report Submitted';
      case 'verified':
        return 'Complaint Verified';
      case 'assigned':
        return 'Department & Officer Assigned';
      case 'inprogress':
      case 'in_progress':
      case 'in progress':
        return 'Work In Progress';
      case 'resolved':
        return 'Problem Officially Resolved';
      case 'rejected':
        return 'Report Rejected';
      default:
        return status;
    }
  }
}
