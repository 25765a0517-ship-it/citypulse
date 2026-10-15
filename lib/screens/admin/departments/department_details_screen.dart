import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/complaint_provider.dart';
import '../../../providers/department_provider.dart';
import '../../../widgets/common/ui_states.dart';
import '../../../widgets/complaint/complaint_card.dart';

class DepartmentDetailsScreen extends ConsumerWidget {
  final String departmentId;

  const DepartmentDetailsScreen({super.key, required this.departmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptsAsync = ref.watch(departmentsFutureProvider);
    final complaintState = ref.watch(complaintProvider);

    final deptComplaints = complaintState.allComplaints.where((c) => c.departmentId == departmentId).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Department Roster'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: deptsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (departments) {
          final dept = departments.firstWhere(
            (d) => d.id == departmentId,
            orElse: () => departments.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Department Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryFixed,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: const Icon(Icons.business, color: AppColors.secondary, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dept.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                                Text('Municipal Code: #${dept.id}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(dept.description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Department Active Officers
                Text('Active Field Crew Officers', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _officerTile('Marcus Vance', 'Badge #4412 • Unit #14 Mobile Utility', 'On Duty (Ward 4)'),
                _officerTile('Elena Rostova', 'Badge #4418 • Unit #08 Rapid Response', 'On Duty (Ward 3)'),
                _officerTile('David Chen', 'Badge #4421 • Unit #22 Heavy Repair', 'On Break'),
                const SizedBox(height: 20),

                // Active Department Complaints
                Text('Active Department Tickets (${deptComplaints.length})', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                if (deptComplaints.isEmpty)
                  const EmptyState(title: 'Queue Clean', message: 'No tickets currently assigned to this department.', icon: Icons.check_circle_outline)
                else
                  ...deptComplaints.map((c) => ComplaintCard(complaint: c, onTap: () => context.push('/admin/complaint/${c.id}'))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _officerTile(String name, String badge, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondary,
            child: Text(name[0], style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                Text(badge, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: status.contains('On Duty') ? AppColors.statusResolvedBg : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              status,
              style: AppTextStyles.labelSmall.copyWith(
                color: status.contains('On Duty') ? AppColors.statusResolved : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
