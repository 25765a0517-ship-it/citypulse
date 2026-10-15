import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/complaint_model.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/complaint_provider.dart';
import '../../../services/routing_service.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/maps/complaint_map_widget.dart';

class OfficerMapScreen extends ConsumerStatefulWidget {
  final String? initialComplaintId;

  const OfficerMapScreen({super.key, this.initialComplaintId});

  @override
  ConsumerState<OfficerMapScreen> createState() => _OfficerMapScreenState();
}

class _OfficerMapScreenState extends ConsumerState<OfficerMapScreen> {
  ComplaintModel? _activeComplaint;
  RouteDetail? _routeDetail;

  @override
  void initState() {
    super.initState();
    final all = ref.read(complaintProvider).allComplaints;
    if (widget.initialComplaintId != null) {
      _activeComplaint = all.firstWhere((c) => c.id == widget.initialComplaintId, orElse: () => all.first);
    } else if (all.isNotEmpty) {
      _activeComplaint = all.first;
    }

    if (_activeComplaint != null) {
      final routing = ref.read(routingServiceProvider);
      _routeDetail = routing.computeRoute(
        startLat: 12.9716,
        startLng: 77.5946,
        endLat: _activeComplaint!.latitude,
        endLng: _activeComplaint!.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);
    final all = complaintState.allComplaints;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Field Navigation & Map'),
      ),
      body: Stack(
        children: [
          ComplaintMapWidget(
            complaints: all,
            showNavigationRoute: true,
            activeRouteComplaint: _activeComplaint,
            onComplaintSelected: (c) {
              setState(() {
                _activeComplaint = c;
                final routing = ref.read(routingServiceProvider);
                _routeDetail = routing.computeRoute(
                  startLat: 12.9716,
                  startLng: 77.5946,
                  endLat: c.latitude,
                  endLng: c.longitude,
                );
              });
            },
          ),

          // Tactical HUD Overlay (Turn-by-turn routing HUD from Stitch)
          if (_activeComplaint != null && _routeDetail != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.turn_right, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _routeDetail!.steps.first.instruction,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ETA: ${_routeDetail!.estimatedDurationMinutes} mins • (${(_routeDetail!.distanceMeters / 1000).toStringAsFixed(1)} km) via Central Expwy',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.surfaceContainerHigh,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Arrived At Site Bottom Action CTA
          if (_activeComplaint != null)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: AppButton(
                label: 'Arrived at Site • Start Resolution',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  context.push('/officer/resolve/${_activeComplaint!.id}');
                },
              ),
            ),
        ],
      ),
    );
  }
}
