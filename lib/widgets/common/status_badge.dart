import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'submitted':
        bg = AppColors.statusSubmittedBg;
        fg = AppColors.statusSubmitted;
        label = 'Submitted';
        icon = Icons.send_outlined;
        break;
      case 'verified':
        bg = AppColors.statusVerifiedBg;
        fg = AppColors.statusVerified;
        label = 'Verified';
        icon = Icons.verified_outlined;
        break;
      case 'assigned':
        bg = AppColors.statusAssignedBg;
        fg = AppColors.statusAssigned;
        label = 'Assigned';
        icon = Icons.assignment_ind_outlined;
        break;
      case 'inprogress':
      case 'in_progress':
      case 'in progress':
        bg = AppColors.statusInProgressBg;
        fg = AppColors.statusInProgress;
        label = 'In Progress';
        icon = Icons.build_circle_outlined;
        break;
      case 'resolved':
        bg = AppColors.statusResolvedBg;
        fg = AppColors.statusResolved;
        label = 'Resolved';
        icon = Icons.check_circle_outline;
        break;
      case 'rejected':
        bg = AppColors.statusRejectedBg;
        fg = AppColors.statusRejected;
        label = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
      default:
        bg = AppColors.surfaceContainer;
        fg = AppColors.onSurfaceVariant;
        label = status;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
