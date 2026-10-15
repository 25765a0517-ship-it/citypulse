import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/complaint_model.dart';
import '../../../models/department_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../providers/department_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/priority_badge.dart';
import '../../../widgets/common/status_badge.dart';

class AdminComplaintDetailsScreen extends ConsumerStatefulWidget {
  final String complaintId;

  const AdminComplaintDetailsScreen({super.key, required this.complaintId});

  @override
  ConsumerState<AdminComplaintDetailsScreen> createState() => _AdminComplaintDetailsScreenState();
}

class _AdminComplaintDetailsScreenState extends ConsumerState<AdminComplaintDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);
    final departmentsAsync = ref.watch(departmentsFutureProvider);
    final authState = ref.watch(authProvider);
    final adminName = authState.user?.name ?? 'Director Sarah Lin';

    final complaint = complaintState.allComplaints.firstWhere(
      (c) => c.id == widget.complaintId,
      orElse: () => complaintState.allComplaints.first,
    );

    final photo = complaint.imageUrls.isNotEmpty ? complaint.imageUrls.first : AppConstants.potholeAsset;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Admin Dossier #${complaint.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo & Status
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              child: Image.asset(
                photo,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(height: 180, color: AppColors.surfaceContainer),
              ),
            ),
            const SizedBox(height: 16),

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
              'Filed by ${complaint.citizenName} • ${Formatters.formatDateTime(complaint.createdAt)}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: 16),

            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Citizen Report', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(complaint.description, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(complaint.address, style: AppTextStyles.bodySmall)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Assignment Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Dispatch Assignment', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Department:', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                      Text(complaint.departmentName ?? 'Unassigned', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Assigned Officer:', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                      Text(complaint.officerName ?? 'Pending Dispatch', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Administrative Actions
            Text('Administrative Triage Actions', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),

            departmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Failed to load departments: $err'),
              data: (departments) => Column(
                children: [
                  AppButton(
                    label: 'Assign Department & Officer',
                    icon: Icons.assignment_ind_outlined,
                    onPressed: () => _showAssignDialog(departments, complaint, adminName),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Change Priority Rating',
                    icon: Icons.flag_outlined,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => _showChangePriorityDialog(complaint, adminName),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'View Timeline Audit Log',
                    icon: Icons.timeline,
                    variant: AppButtonVariant.outline,
                    onPressed: () => context.push('/citizen/complaint/${complaint.id}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(List<DepartmentModel> departments, ComplaintModel complaint, String adminName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Step 1: Select Department', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...departments.map((dept) {
              return ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.business, color: AppColors.secondary, size: 20),
                ),
                title: Text(dept.name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text('${dept.officerCount} active officers available', style: AppTextStyles.bodySmall),
                onTap: () {
                  Navigator.pop(ctx);
                  _showOfficerSelectionDialog(dept, complaint, adminName);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showOfficerSelectionDialog(DepartmentModel department, ComplaintModel complaint, String adminName) {
    final officers = [
      UserModel(
        uid: 'officer_202',
        name: 'Marcus Vance',
        email: 'marcus@citypulse.gov',
        role: UserRole.officer,
        departmentId: department.id,
        badgeNumber: '4412',
        availability: 'Available (Active on Ward 4)',
      ),
      UserModel(
        uid: 'officer_203',
        name: 'Elena Rostova',
        email: 'elena@citypulse.gov',
        role: UserRole.officer,
        departmentId: department.id,
        badgeNumber: '4418',
        availability: 'Available (Ward 3/4)',
      ),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Step 2: Assign Officer (${department.name})', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...officers.map((officer) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  child: Text(officer.name[0], style: const TextStyle(color: Colors.white)),
                ),
                title: Text(officer.name, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                subtitle: Text('Badge #${officer.badgeNumber} • ${officer.availability}', style: AppTextStyles.bodySmall),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref.read(complaintProvider.notifier).assignDepartmentAndOfficer(
                        complaintId: complaint.id,
                        departmentId: department.id,
                        departmentName: department.name,
                        officerId: officer.uid,
                        officerName: officer.name,
                        adminName: adminName,
                      );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Complaint assigned to ${department.name} • ${officer.name}')),
                    );
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showChangePriorityDialog(ComplaintModel complaint, String adminName) {
    final priorities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Update Priority Rating'),
        children: priorities.map((p) {
          return SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(ctx);
              final updated = complaint.copyWith(priority: p);
              await ref.read(complaintRepositoryProvider).submitComplaint(complaint: updated);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Priority updated to $p')),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p, style: const TextStyle(fontWeight: FontWeight.bold)),
                PriorityBadge(priority: p),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
