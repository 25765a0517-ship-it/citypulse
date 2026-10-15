import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/complaint_provider.dart';

class CityAnalyticsScreen extends ConsumerStatefulWidget {
  const CityAnalyticsScreen({super.key});

  @override
  ConsumerState<CityAnalyticsScreen> createState() => _CityAnalyticsScreenState();
}

class _CityAnalyticsScreenState extends ConsumerState<CityAnalyticsScreen> {
  String _selectedPeriod = '30 Days';

  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);
    final all = complaintState.allComplaints;

    final total = all.length;
    final resolved = all.where((c) => c.status == 'resolved').length;
    final active = all.where((c) => c.status != 'resolved' && c.status != 'rejected').length;
    final resolutionRate = total > 0 ? ((resolved / total) * 100).toStringAsFixed(1) : '0';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('City Analytics & SLA Intelligence'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filter Buttons
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: ['Today', '7 Days', '30 Days', 'All Time'].map((p) {
                  final isSel = _selectedPeriod == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPeriod = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.surfaceContainerLowest : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          p,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            color: isSel ? AppColors.secondary : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Top Metrics 2x2
            Row(
              children: [
                Expanded(
                  child: _metricCard('Total Volume', total.toString(), 'Municipal Reports', AppColors.secondary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metricCard('Resolution Rate', '$resolutionRate%', 'Target: >90%', AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _metricCard('Avg Resolution', '4h 12m', 'SLA Compliant', AppColors.warning),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _metricCard('Active In-Flight', active.toString(), 'Crews dispatched', AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Department SLA Performance
            Text('Department SLA Compliance', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                children: [
                  _slaRow('Roads & Infrastructure', 0.94, '94% SLA (Target met)'),
                  const SizedBox(height: 12),
                  _slaRow('Waste Management', 0.91, '91% SLA (Target met)'),
                  const SizedBox(height: 12),
                  _slaRow('Water & Utilities', 0.88, '88% SLA (Review queue)'),
                  const SizedBox(height: 12),
                  _slaRow('Street Lighting', 0.96, '96% SLA (Exemplary)'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Category Severity Breakdown
            Text('Category Severity Distribution', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                children: AppConstants.categories.map((cat) {
                  final count = all.where((c) => c.category.toLowerCase() == cat.toLowerCase()).length;
                  final pct = total > 0 ? (count / total) : 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(width: 110, child: Text(cat, style: AppTextStyles.labelMedium)),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: AppColors.surfaceContainer,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                            borderRadius: BorderRadius.circular(4),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('$count (${(pct * 100).toStringAsFixed(0)}%)', style: AppTextStyles.labelSmall),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String title, String val, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 6),
          Text(val, style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.outline)),
        ],
      ),
    );
  }

  Widget _slaRow(String dept, double progress, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dept, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600)),
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.surfaceContainer,
          valueColor: AlwaysStoppedAnimation<Color>(progress >= 0.9 ? AppColors.success : AppColors.warning),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}
