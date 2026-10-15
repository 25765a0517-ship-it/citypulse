import 'package:geolocator/geolocator.dart';
import '../models/complaint_model.dart';

class DuplicateMatch {
  final ComplaintModel existingComplaint;
  final double distanceMeters;
  final double similarityScore; // 0.0 to 1.0

  DuplicateMatch({
    required this.existingComplaint,
    required this.distanceMeters,
    required this.similarityScore,
  });
}

class DuplicateDetectionService {
  static const double duplicateThresholdRadiusMeters = 100.0; // 100 meters

  List<DuplicateMatch> findDuplicates({
    required String category,
    required double latitude,
    required double longitude,
    required List<ComplaintModel> activeComplaints,
  }) {
    final matches = <DuplicateMatch>[];

    for (final complaint in activeComplaints) {
      // Only compare with complaints that are active (not resolved/rejected)
      if (complaint.status == 'resolved' || complaint.status == 'rejected') {
        continue;
      }

      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        complaint.latitude,
        complaint.longitude,
      );

      final isSameCategory = complaint.category.trim().toLowerCase() == category.trim().toLowerCase();

      // Rule: If same category and within 100m, high duplicate probability
      if (isSameCategory && distance <= duplicateThresholdRadiusMeters) {
        final score = (1.0 - (distance / duplicateThresholdRadiusMeters)).clamp(0.5, 0.99);
        matches.add(DuplicateMatch(
          existingComplaint: complaint,
          distanceMeters: distance,
          similarityScore: score,
        ));
      } else if (distance <= 40.0) {
        // Different category but very close proximity (under 40m)
        matches.add(DuplicateMatch(
          existingComplaint: complaint,
          distanceMeters: distance,
          similarityScore: 0.65,
        ));
      }
    }

    // Sort by highest similarity score first
    matches.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));
    return matches;
  }
}
