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
import '../../../providers/location_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/priority_badge.dart';
import '../../../widgets/complaint/category_card.dart';

class ReportWizardScreen extends ConsumerStatefulWidget {
  final int initialStep;

  const ReportWizardScreen({super.key, this.initialStep = 1});

  @override
  ConsumerState<ReportWizardScreen> createState() => _ReportWizardScreenState();
}

class _ReportWizardScreenState extends ConsumerState<ReportWizardScreen> {
  late int _currentStep;
  final TextEditingController _descController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    final draft = ref.read(complaintProvider).draft;
    _descController.text = draft.description;
    _isAnonymous = draft.isAnonymous;
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        ref.read(complaintProvider.notifier).addDraftPhoto(File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access camera/gallery: $e')),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      if (_descController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please describe the problem.')),
        );
        return;
      }
      ref.read(complaintProvider.notifier).updateDraftDescription(_descController.text.trim());
      setState(() => _currentStep = 4);
    } else if (_currentStep == 4) {
      // Step 4 triggers Duplicate Check & Priority pipeline
      _showDuplicateCheckAndSubmitPipeline();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep -= 1);
    } else {
      context.pop();
    }
  }

  void _showDuplicateCheckAndSubmitPipeline() {
    final complaintState = ref.read(complaintProvider);
    final duplicates = complaintState.detectedDuplicates;

    if (duplicates.isNotEmpty) {
      // Show Duplicate Detection Sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _buildDuplicateSheet(ctx, duplicates),
      );
    } else {
      // Proceed directly to Priority Preview & Confirmation
      _showPriorityPreviewModal();
    }
  }

  Widget _buildDuplicateSheet(BuildContext ctx, List<dynamic> duplicates) {
    return Container(
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
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.warningContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.copy_all, color: AppColors.warning, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Similar Report Nearby Found',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'A report with matching category was filed within 100 meters.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Duplicates preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Existing Ticket: ${duplicates.first.existingComplaint.id}',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  duplicates.first.existingComplaint.description,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurface),
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.near_me, size: 12, color: AppColors.outline),
                    const SizedBox(width: 4),
                    Text(
                      '${duplicates.first.distanceMeters.toStringAsFixed(0)} meters away',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline, fontSize: 11),
                    ),
                    const Spacer(),
                    Text(
                      'Upvotes: ${duplicates.first.existingComplaint.supportCount}',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Support Existing',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    ref.read(complaintProvider.notifier).supportComplaint(duplicates.first.existingComplaint.id);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Supported existing report! We will notify you of updates.')),
                    );
                    context.pop();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Submit Anyway',
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showPriorityPreviewModal();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPriorityPreviewModal() {
    final draft = ref.read(complaintProvider).draft;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Automated Priority Assessment',
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Calculated based on municipal hazard matrices and location density.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // Priority Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assigned Urgency Rating',
                        style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      PriorityBadge(priority: draft.calculatedPriority),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Severity Score: ${draft.severityScore} / 100',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    draft.priorityReason,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Anonymity Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submit Anonymously',
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Hide my identity on public city maps',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                Switch(
                  value: _isAnonymous,
                  activeThumbColor: AppColors.secondary,
                  onChanged: (val) {
                    setState(() => _isAnonymous = val);
                    Navigator.pop(ctx);
                    _showPriorityPreviewModal();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            AppButton(
              label: 'Confirm & Submit Ticket',
              trailingIcon: Icons.check,
              onPressed: () {
                Navigator.pop(ctx);
                _executeSubmission();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeSubmission() async {
    final user = ref.read(authProvider).user;
    final citizenId = user?.uid ?? 'citizen_101';
    final citizenName = user?.name ?? 'Citizen Alex';

    try {
      final ticketId = await ref.read(complaintProvider.notifier).submitCurrentDraft(
            citizenId: citizenId,
            citizenName: citizenName,
          );

      if (mounted) {
        _showSuccessScreen(ticketId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission error: $e')),
        );
      }
    }
  }

  void _showSuccessScreen(String ticketId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  'Report Submitted Successfully!',
                  style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Your complaint has been logged and assigned to the municipal dispatch queue.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryFixed,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Text(
                    'Ticket ID: $ticketId',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSecondaryFixedVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                AppButton(
                  label: 'View Ticket Details',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/citizen/complaint/$ticketId');
                  },
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Back to Home',
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/citizen');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(complaintProvider).draft;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Report Problem (Step $_currentStep of 4)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: _currentStep / 4.0,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildStepContent(draft),
              ),
            ),

            // Bottom Continue CTA
            Padding(
              padding: const EdgeInsets.all(20),
              child: AppButton(
                label: _currentStep == 4 ? 'Review & Submit Report' : 'Continue',
                trailingIcon: Icons.arrow_forward,
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(ComplaintDraft draft) {
    switch (_currentStep) {
      case 1:
        return _buildCategoryStep(draft);
      case 2:
        return _buildPhotoStep(draft);
      case 3:
        return _buildDescriptionStep(draft);
      case 4:
        return _buildLocationStep(draft);
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: CATEGORY
  Widget _buildCategoryStep(ComplaintDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Problem Category',
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose the option that best describes the municipal issue.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: AppConstants.categories.map((category) {
            final isSelected = draft.category.toLowerCase() == category.toLowerCase();
            return CategoryCard(
              title: category,
              icon: CategoryCard.getIconForCategory(category),
              isSelected: isSelected,
              onTap: () {
                ref.read(complaintProvider.notifier).updateDraftCategory(category);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 2: PHOTO
  Widget _buildPhotoStep(ComplaintDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Photo Evidence',
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Clear photographs help road crews and inspectors identify and triage quickly.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),

        // Photo Upload Options
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _pickImage(ImageSource.camera),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, color: AppColors.secondary, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Take Photo',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _pickImage(ImageSource.gallery),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.photo_library, color: AppColors.onSurfaceVariant, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Choose Gallery',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Preview Attached Photos
        if (draft.photos.isNotEmpty) ...[
          Text(
            'Attached Photos (${draft.photos.length}):',
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: draft.photos.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        image: DecorationImage(
                          image: FileImage(draft.photos[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => ref.read(complaintProvider.notifier).removeDraftPhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ] else ...[
          // Default asset reference preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.asset(
                    'assets/images/pothole.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Default Category Graphic',
                        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'If you skip uploading a photo, a standard verified civic category image will be attached.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // STEP 3: DESCRIPTION
  Widget _buildDescriptionStep(ComplaintDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe the Problem',
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Provide details such as size, severity, duration, or any safety concerns.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        AppTextField(
          hint: 'e.g. Deep pothole across eastbound lane near crossroad, damaging car rims...',
          controller: _descController,
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates_outlined, color: AppColors.secondary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mentioning words like "danger", "burst", or "accident" automatically triggers high-urgency triage.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSecondaryFixedVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 4: LOCATION
  Widget _buildLocationStep(ComplaintDraft draft) {
    final locationAsync = ref.watch(currentLocationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Location',
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Pinpoint the exact location of the issue for the dispatch crew.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),

        // Map Preview Container
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            image: const DecorationImage(
              image: AssetImage('assets/images/map_overview.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'GPS Accurate ±2m',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Current Location Address Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.my_location, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detected Street Address',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      draft.address,
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Lat: ${draft.latitude.toStringAsFixed(4)}, Lng: ${draft.longitude.toStringAsFixed(4)}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Location Action Buttons
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Use GPS',
                icon: Icons.gps_fixed,
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  locationAsync.whenData((loc) {
                    ref.read(complaintProvider.notifier).updateDraftLocation(
                          lat: loc.latitude,
                          lng: loc.longitude,
                          address: loc.address,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Updated to current GPS position!')),
                    );
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                label: 'Adjust Pin',
                icon: Icons.edit_location_alt_outlined,
                variant: AppButtonVariant.outline,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pin centered on reported hazard location.')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
