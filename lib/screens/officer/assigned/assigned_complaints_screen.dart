import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/complaint_model.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/common/ui_states.dart';
import '../../../widgets/complaint/complaint_card.dart';

class AssignedComplaintsScreen extends ConsumerStatefulWidget {
  const AssignedComplaintsScreen({super.key});

  @override
  ConsumerState<AssignedComplaintsScreen> createState() => _AssignedComplaintsScreenState();
}

class _AssignedComplaintsScreenState extends ConsumerState<AssignedComplaintsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);
    final all = complaintState.allComplaints;

    final assigned = all.where((c) => c.status == 'assigned').toList();
    final highPriority = all.where((c) => c.priority == 'HIGH' || c.priority == 'CRITICAL').toList();
    final inProgress = all.where((c) => c.status == 'inProgress').toList();
    final resolved = all.where((c) => c.status == 'resolved').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assigned Queue'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.secondary,
          labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'All (${all.length})'),
            Tab(text: 'New (${assigned.length})'),
            Tab(text: 'Critical/High (${highPriority.length})'),
            Tab(text: 'In Progress (${inProgress.length})'),
            Tab(text: 'Resolved (${resolved.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQueueList(all, 'No complaints in queue.'),
          _buildQueueList(assigned, 'No newly assigned tickets.'),
          _buildQueueList(highPriority, 'No high priority tickets at this time.'),
          _buildQueueList(inProgress, 'No tickets currently marked in progress.'),
          _buildQueueList(resolved, 'No resolved tickets.'),
        ],
      ),
    );
  }

  Widget _buildQueueList(List<ComplaintModel> list, String empty) {
    if (list.isEmpty) {
      return EmptyState(title: 'Queue Clear', message: empty, icon: Icons.done_all);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final complaint = list[index];
        return ComplaintCard(
          complaint: complaint,
          onTap: () => context.push('/officer/complaint/${complaint.id}'),
        );
      },
    );
  }
}
