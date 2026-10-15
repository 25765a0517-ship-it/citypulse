import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/complaint_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

class CompleteResolutionScreen extends ConsumerStatefulWidget {
  final String complaintId;

  const CompleteResolutionScreen({super.key, required this.complaintId});

  @override
  ConsumerState<CompleteResolutionScreen> createState() => _CompleteResolutionScreenState();
}

class _CompleteResolutionScreenState extends ConsumerState<CompleteResolutionScreen> {
  final _notesController = TextEditingController(text: 'Hazard safely rectified and subsurface compacted with cold-mix asphalt.');
  File? _resolutionPhoto;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() => _resolutionPhoto = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access camera/gallery: $e')),
        );
      }
    }
  }

  void _confirmAndSubmit() {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the work completed.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark Work Order as Resolved?'),
        content: const Text(
          'This will permanently certify site restoration, upload resolution evidence, and dispatch a completion notification to the reporting citizen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeResolution();
            },
            child: const Text('Confirm Resolution', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeResolution() async {
    setState(() => _isSubmitting = true);
    final authState = ref.read(authProvider);
    final officerName = authState.user?.name ?? 'Marcus Vance';

    try {
      await ref.read(complaintProvider.notifier).resolveComplaint(
            complaintId: widget.complaintId,
            officerName: officerName,
            resolutionNotes: _notesController.text.trim(),
            resolutionPhoto: _resolutionPhoto,
          );

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint officially resolved and citizen notified!')),
        );
        context.go('/officer');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resolution error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);
    final complaint = complaintState.allComplaints.firstWhere(
      (c) => c.id == widget.complaintId,
      orElse: () => complaintState.allComplaints.first,
    );

    final originalPhoto = complaint.imageUrls.isNotEmpty ? complaint.imageUrls.first : AppConstants.potholeAsset;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Complete Work Resolution'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original Hazard Reference
            Text('Original Citizen Report Evidence', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Image.asset(
                originalPhoto,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(height: 140, color: AppColors.surfaceContainer),
              ),
            ),
            const SizedBox(height: 20),

            // Resolution Photo Upload Area
            Text('Resolution After-Photo (Required)', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (_resolutionPhoto != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: Image.file(
                      _resolutionPhoto!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _resolutionPhoto = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.camera_alt, color: AppColors.secondary),
                      label: const Text('Capture Camera'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    const VerticalDivider(width: 1),
                    TextButton.icon(
                      icon: const Icon(Icons.photo_library, color: AppColors.onSurfaceVariant),
                      label: const Text('Pick Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Resolution Notes
            Text('Work Procedure & Materials Used', style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            AppTextField(
              hint: 'e.g. Cleared debris, applied 50kg asphalt patch, compacted surface...',
              controller: _notesController,
              maxLines: 4,
            ),
            const SizedBox(height: 28),

            // Submit Button
            AppButton(
              label: 'Certify & Mark as Resolved',
              icon: Icons.verified,
              isLoading: _isSubmitting,
              onPressed: _confirmAndSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
