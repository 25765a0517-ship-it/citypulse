import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/complaint_model.dart';
import '../common/priority_badge.dart';
import '../common/status_badge.dart';

class ComplaintMapWidget extends StatefulWidget {
  final List<ComplaintModel> complaints;
  final ValueChanged<ComplaintModel>? onComplaintSelected;
  final bool showNavigationRoute;
  final ComplaintModel? activeRouteComplaint;

  const ComplaintMapWidget({
    super.key,
    required this.complaints,
    this.onComplaintSelected,
    this.showNavigationRoute = false,
    this.activeRouteComplaint,
  });

  @override
  State<ComplaintMapWidget> createState() => _ComplaintMapWidgetState();
}

class _ComplaintMapWidgetState extends State<ComplaintMapWidget> {
  ComplaintModel? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.activeRouteComplaint != null) {
      _selected = widget.activeRouteComplaint;
    } else if (widget.complaints.isNotEmpty) {
      _selected = widget.complaints.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map Surface Graphic (Vector Map representation from Stitch)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFE8EEF5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                widget.showNavigationRoute
                    ? 'assets/images/map_navigation.png'
                    : 'assets/images/map_overview.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(Icons.map, size: 64, color: AppColors.outlineVariant),
                ),
              ),
              // Render Semantic Pins on Map
              ..._renderPins(),
            ],
          ),
        ),

        // Map Control Overlays
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _mapActionButton(
                icon: Icons.my_location,
                tooltip: 'My Location',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Centered on current GPS coordinates (Ward 4)'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _mapActionButton(
                icon: Icons.layers_outlined,
                tooltip: 'Map Layers',
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Live Selected Complaint Card Overlay (Stitch Bottom Sheet Callout)
        if (_selected != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: AppColors.surfaceContainer,
                      child: Image.asset(
                        _selected!.imageUrls.isNotEmpty
                            ? _selected!.imageUrls.first
                            : 'assets/images/pothole.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.report),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              _selected!.category,
                              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            StatusBadge(status: _selected!.status),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selected!.address,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            PriorityBadge(priority: _selected!.priority),
                            const Spacer(),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                widget.onComplaintSelected?.call(_selected!);
                              },
                              child: Text(
                                'View Ticket →',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _mapActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.onSurface, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  List<Widget> _renderPins() {
    // Generate deterministic visual pins across map space
    final positions = [
      const Offset(0.35, 0.40),
      const Offset(0.65, 0.32),
      const Offset(0.25, 0.65),
      const Offset(0.70, 0.60),
      const Offset(0.50, 0.50),
    ];

    final widgets = <Widget>[];

    for (int i = 0; i < widget.complaints.length; i++) {
      final complaint = widget.complaints[i];
      final pos = positions[i % positions.length];
      final isSelected = _selected?.id == complaint.id;

      widgets.add(
        Positioned(
          left: MediaQuery.of(context).size.width * pos.dx,
          top: 300 * pos.dy + 80,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selected = complaint;
              });
            },
            child: AnimatedScale(
              scale: isSelected ? 1.25 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getPingColor(complaint.priority),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _getPingIcon(complaint.category),
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Color _getPingColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.priorityCritical;
      case 'HIGH':
        return AppColors.priorityHigh;
      case 'MEDIUM':
        return AppColors.priorityMedium;
      case 'LOW':
      default:
        return AppColors.priorityLow;
    }
  }

  IconData _getPingIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pothole':
        return Icons.warning_rounded;
      case 'streetlight':
        return Icons.lightbulb;
      case 'garbage':
        return Icons.delete;
      case 'water leakage':
        return Icons.water_drop;
      default:
        return Icons.location_on;
    }
  }
}
