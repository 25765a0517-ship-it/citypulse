import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        bg = AppColors.priorityCriticalBg;
        fg = AppColors.priorityCritical;
        label = 'CRITICAL';
        icon = Icons.error_outline;
        break;
      case 'HIGH':
        bg = AppColors.priorityHighBg;
        fg = AppColors.priorityHigh;
        label = 'HIGH';
        icon = Icons.warning_amber_rounded;
        break;
      case 'MEDIUM':
        bg = AppColors.priorityMediumBg;
        fg = AppColors.priorityMedium;
        label = 'MEDIUM';
        icon = Icons.speed;
        break;
      case 'LOW':
      default:
        bg = AppColors.priorityLowBg;
        fg = AppColors.priorityLow;
        label = 'LOW';
        icon = Icons.low_priority;
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
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
