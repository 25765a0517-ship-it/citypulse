import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/complaint/complaint_card.dart';
import '../../../widgets/maps/complaint_map_widget.dart';

class CitizenMapScreen extends ConsumerStatefulWidget {
  const CitizenMapScreen({super.key});

  @override
  ConsumerState<CitizenMapScreen> createState() => _CitizenMapScreenState();
}

class _CitizenMapScreenState extends ConsumerState<CitizenMapScreen> {
  bool _isListView = false;
  String _selectedCategory = 'All';
  final String _selectedPriority = 'All';

  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);
    var filtered = complaintState.allComplaints;

    if (_selectedCategory != 'All') {
      filtered = filtered.where((c) => c.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }
    if (_selectedPriority != 'All') {
      filtered = filtered.where((c) => c.priority.toUpperCase() == _selectedPriority.toUpperCase()).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nearby Hazards Map'),
        actions: [
          IconButton(
            icon: Icon(_isListView ? Icons.map_outlined : Icons.view_list_outlined),
            tooltip: _isListView ? 'Show Map' : 'Show List',
            onPressed: () => setState(() => _isListView = !_isListView),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceContainerLowest,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip(
                    label: 'All Categories',
                    isSelected: _selectedCategory == 'All',
                    onSelected: () => setState(() => _selectedCategory = 'All'),
                  ),
                  const SizedBox(width: 8),
                  ...AppConstants.categories.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _filterChip(
                          label: cat,
                          isSelected: _selectedCategory == cat,
                          onSelected: () => setState(() => _selectedCategory = cat),
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Main View: Map or List
          Expanded(
            child: _isListView
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final complaint = filtered[index];
                      return ComplaintCard(
                        complaint: complaint,
                        onTap: () => context.push('/citizen/complaint/${complaint.id}'),
                      );
                    },
                  )
                : ComplaintMapWidget(
                    complaints: filtered,
                    onComplaintSelected: (complaint) {
                      context.push('/citizen/complaint/${complaint.id}');
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.secondaryFixed,
      backgroundColor: AppColors.surfaceContainerLow,
      labelStyle: AppTextStyles.labelSmall.copyWith(
        color: isSelected ? AppColors.onSecondaryFixedVariant : AppColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
      side: BorderSide.none,
      onSelected: (_) => onSelected(),
    );
  }
}
