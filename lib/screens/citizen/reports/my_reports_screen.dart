import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/complaint_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/common/ui_states.dart';
import '../../../widgets/complaint/complaint_card.dart';

class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final complaintState = ref.watch(complaintProvider);
    final userId = authState.user?.uid ?? 'citizen_101';

    final myComplaints = complaintState.allComplaints.where((c) => c.citizenId == userId).toList();

    final pending = myComplaints.where((c) => c.status == 'submitted' || c.status == 'verified').toList();
    final inProgress = myComplaints.where((c) => c.status == 'assigned' || c.status == 'inProgress').toList();
    final resolved = myComplaints.where((c) => c.status == 'resolved').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Reports'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'All (${myComplaints.length})'),
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Active (${inProgress.length})'),
            Tab(text: 'Resolved (${resolved.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(myComplaints, 'No reports filed yet.'),
          _buildList(pending, 'No pending complaints currently.'),
          _buildList(inProgress, 'No complaints currently under repair.'),
          _buildList(resolved, 'No resolved complaints yet.'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('New Report'),
        onPressed: () => context.push('/citizen/report/step-1'),
      ),
    );
  }

  Widget _buildList(List<ComplaintModel> items, String emptyMsg) {
    if (items.isEmpty) {
      return EmptyState(
        title: 'Empty queue',
        message: emptyMsg,
        icon: Icons.assignment_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final complaint = items[index];
        return ComplaintCard(
          complaint: complaint,
          onTap: () => context.push('/citizen/complaint/${complaint.id}'),
        );
      },
    );
  }
}
