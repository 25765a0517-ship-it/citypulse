import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _wardController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
    _wardController.text = user?.ward ?? 'Ward 4 • Downtown North';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final user = ref.read(authProvider).user;
    if (user != null) {
      final updated = user.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        ward: _wardController.text.trim(),
      );
      await ref.read(userRepositoryProvider).saveUser(updated);
      ref.read(authProvider.notifier).refreshUser();
    }
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryContainer,
                    backgroundImage: const AssetImage(AppConstants.citizenAvatarAsset),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Full Name',
              hint: 'Your name',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone Number',
              hint: '+1 (555) 000-0000',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Neighborhood Ward',
              hint: 'Ward 4 • Downtown North',
              controller: _wardController,
              prefixIcon: Icons.location_city_outlined,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Save Changes',
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
