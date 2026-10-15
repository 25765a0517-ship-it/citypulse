import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/complaint/complaint_card.dart';

class AllComplaintsScreen extends ConsumerStatefulWidget {
  const AllComplaintsScreen({super.key});

  @override
  ConsumerState<AllComplaintsScreen> createState() => _AllComplaintsScreenState();
}

class _AllComplaintsScreenState extends ConsumerState<AllComplaintsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);
    final query = _searchController.text.trim().toLowerCase();

    var filtered = complaintState.allComplaints.where((c) {
      if (query.isNotEmpty) {
        final matchesId = c.id.toLowerCase().contains(query);
        final matchesCat = c.category.toLowerCase().contains(query);
        final matchesLoc = c.address.toLowerCase().contains(query);
        final matchesDesc = c.description.toLowerCase().contains(query);
        if (!matchesId && !matchesCat && !matchesLoc && !matchesDesc) return false;
      }
      if (_selectedStatus != 'All' && c.status.toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }
      if (_selectedPriority != 'All' && c.priority.toUpperCase() != _selectedPriority.toUpperCase()) {
        return false;
      }
      if (_selectedCategory != 'All' && c.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('All Municipal Complaints'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by ID, Category, or Street...',
                prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _filterButton('Status: $_selectedStatus', () => _showFilterDialog('status')),
                const SizedBox(width: 8),
                _filterButton('Priority: $_selectedPriority', () => _showFilterDialog('priority')),
                const SizedBox(width: 8),
                _filterButton('Category: $_selectedCategory', () => _showFilterDialog('category')),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filtered.length} tickets',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline),
                ),
                if (_selectedStatus != 'All' || _selectedPriority != 'All' || _selectedCategory != 'All')
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'All';
                        _selectedPriority = 'All';
                        _selectedCategory = 'All';
                      });
                    },
                    child: Text(
                      'Clear Filters',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final complaint = filtered[index];
                return ComplaintCard(
                  complaint: complaint,
                  showOfficerDetails: true,
                  onTap: () => context.push('/admin/complaint/${complaint.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurface)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(String type) {
    List<String> options = [];
    String current = '';
    if (type == 'status') {
      options = ['All', 'submitted', 'verified', 'assigned', 'inProgress', 'resolved'];
      current = _selectedStatus;
    } else if (type == 'priority') {
      options = ['All', 'CRITICAL', 'HIGH', 'MEDIUM', 'LOW'];
      current = _selectedPriority;
    } else {
      options = ['All', ...AppConstants.categories];
      current = _selectedCategory;
    }

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Select Filter', style: AppTextStyles.titleMedium),
        children: options.map((opt) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() {
                if (type == 'status') _selectedStatus = opt;
                if (type == 'priority') _selectedPriority = opt;
                if (type == 'category') _selectedCategory = opt;
              });
              Navigator.pop(ctx);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(opt),
                if (opt.toLowerCase() == current.toLowerCase())
                  const Icon(Icons.check, color: AppColors.secondary, size: 18),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
