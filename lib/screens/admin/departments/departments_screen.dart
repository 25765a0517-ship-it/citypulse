import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/department_provider.dart';
import '../../../widgets/common/ui_states.dart';

class DepartmentsScreen extends ConsumerWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deptsAsync = ref.watch(departmentsFutureProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Municipal Departments'),
      ),
      body: deptsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading departmental roster...'),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (departments) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final dept = departments[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.business_outlined, color: AppColors.secondary, size: 24),
                  ),
                  title: Text(dept.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(dept.description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _chip('${dept.officerCount} Officers', AppColors.surfaceContainer),
                          const SizedBox(width: 6),
                          _chip('${dept.activeComplaints} Active', AppColors.warningContainer),
                          const SizedBox(width: 6),
                          _chip('${dept.resolvedComplaints} Resolved', AppColors.statusResolvedBg),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.outline),
                  onTap: () => context.push('/admin/department/${dept.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _chip(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
