import '../core/constants/app_constants.dart';

class PriorityAssessment {
  final String priority;
  final String reason;
  final int severityScore; // 1 to 100

  PriorityAssessment({
    required this.priority,
    required this.reason,
    required this.severityScore,
  });
}

class PriorityService {
  PriorityAssessment calculatePriority({
    required String category,
    required String description,
    required int nearbyReportsCount,
  }) {
    final lowerDesc = description.toLowerCase();
    int score = 40; // Default baseline (MEDIUM)
    final reasons = <String>[];

    // 1. Category-specific urgency weights
    switch (category.toLowerCase()) {
      case 'water leakage':
        score += 25;
        reasons.add('Water loss/utility hazard');
        break;
      case 'traffic':
        score += 30;
        reasons.add('Active arterial traffic blockage');
        break;
      case 'pothole':
        score += 20;
        reasons.add('Vehicle impact & safety risk');
        break;
      case 'streetlight':
        score += 15;
        reasons.add('Nighttime pedestrian illumination');
        break;
      case 'garbage':
        score += 10;
        reasons.add('Sanitation & environmental impact');
        break;
      default:
        score += 5;
    }

    // 2. Keyword severity inspection
    if (lowerDesc.contains('danger') ||
        lowerDesc.contains('hazard') ||
        lowerDesc.contains('accident') ||
        lowerDesc.contains('deep') ||
        lowerDesc.contains('burst') ||
        lowerDesc.contains('blocked') ||
        lowerDesc.contains('emergency')) {
      score += 25;
      reasons.add('High-hazard keywords flagged in description');
    }

    // 3. Cluster count / multiple citizen impact
    if (nearbyReportsCount >= 3) {
      score += 20;
      reasons.add('Multiple corroborating reports within vicinity ($nearbyReportsCount citizen reports)');
    } else if (nearbyReportsCount >= 1) {
      score += 10;
      reasons.add('Corroborated by existing nearby tickets');
    }

    // Determine final band
    String priority;
    if (score >= 80) {
      priority = AppConstants.priorityCritical;
    } else if (score >= 60) {
      priority = AppConstants.priorityHigh;
    } else if (score >= 35) {
      priority = AppConstants.priorityMedium;
    } else {
      priority = AppConstants.priorityLow;
    }

    final reasonStr = reasons.isNotEmpty
        ? reasons.join('. ')
        : 'Standard municipal SLA assessment based on $category report.';

    return PriorityAssessment(
      priority: priority,
      reason: reasonStr,
      severityScore: score.clamp(1, 100),
    );
  }
}
