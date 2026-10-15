import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailDigest = true;
  bool _locationSharing = true;
  bool _highAccuracyGps = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('NOTIFICATIONS & DISPATCH'),
          _toggleTile(
            title: 'Push Alerts',
            subtitle: 'Immediate updates when complaint status changes',
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          _toggleTile(
            title: 'Daily Municipal Digest',
            subtitle: 'Summary of community fixes in your neighborhood',
            value: _emailDigest,
            onChanged: (val) => setState(() => _emailDigest = val),
          ),
          const SizedBox(height: 20),
          _sectionTitle('LOCATION & TELEMETRY'),
          _toggleTile(
            title: 'Auto-Locate on Launch',
            subtitle: 'Automatically center GPS coordinates on Ward 4',
            value: _locationSharing,
            onChanged: (val) => setState(() => _locationSharing = val),
          ),
          _toggleTile(
            title: 'High-Precision GPS (±1.5m)',
            subtitle: 'Recommended for precise pothole and pipeline geotags',
            value: _highAccuracyGps,
            onChanged: (val) => setState(() => _highAccuracyGps = val),
          ),
          const SizedBox(height: 20),
          _sectionTitle('ABOUT CITYPULSE'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CityPulse Metropolitan Platform', style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Version 1.0.0 (Hackathon Release • Material 3)', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Text('Designed with Google Stitch design system tokens.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onSurfaceVariant,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
        value: value,
        activeThumbColor: AppColors.secondary,
        onChanged: onChanged,
      ),
    );
  }
}
