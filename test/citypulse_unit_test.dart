import 'package:flutter_test/flutter_test.dart';
import 'package:citypulse/core/constants/app_constants.dart';
import 'package:citypulse/models/complaint_model.dart';
import 'package:citypulse/models/user_model.dart';
import 'package:citypulse/services/priority_service.dart';
import 'package:citypulse/services/duplicate_detection_service.dart';
import 'package:citypulse/services/firestore_service.dart';

void main() {
  group('CityPulse Priority Service Tests', () {
    final priorityService = PriorityService();

    test('High hazard keywords elevate priority to CRITICAL', () {
      final assessment = priorityService.calculatePriority(
        category: 'Water Leakage',
        description: 'Major underground burst pipe danger flooding street',
        nearbyReportsCount: 2,
      );

      expect(assessment.priority, AppConstants.priorityCritical);
      expect(assessment.severityScore, greaterThanOrEqualTo(80));
      expect(assessment.reason.contains('Water loss'), true);
      expect(assessment.reason.contains('keywords flagged'), true);
    });

    test('Standard garbage report without urgency keywords yields LOW/MEDIUM', () {
      final assessment = priorityService.calculatePriority(
        category: 'Garbage',
        description: 'Small litter on corner',
        nearbyReportsCount: 0,
      );

      expect(assessment.priority, isIn([AppConstants.priorityLow, AppConstants.priorityMedium]));
      expect(assessment.severityScore, lessThan(60));
    });
  });

  group('CityPulse Duplicate Detection Service Tests', () {
    final duplicateService = DuplicateDetectionService();

    test('Detects duplicate complaint within 100m radius with matching category', () {
      final active = [
        ComplaintModel(
          id: 'CP-100',
          citizenId: 'c1',
          citizenName: 'Citizen A',
          category: 'Pothole',
          description: 'Deep road crack',
          latitude: 12.9716,
          longitude: 77.5946,
          address: 'Main St',
          status: 'submitted',
        ),
      ];

      // Test point within ~30m
      final matches = duplicateService.findDuplicates(
        category: 'Pothole',
        latitude: 12.9718,
        longitude: 77.5948,
        activeComplaints: active,
      );

      expect(matches.isNotEmpty, true);
      expect(matches.first.existingComplaint.id, 'CP-100');
      expect(matches.first.similarityScore, greaterThan(0.5));
    });

    test('Ignores resolved complaints for duplicate check', () {
      final active = [
        ComplaintModel(
          id: 'CP-200',
          citizenId: 'c1',
          citizenName: 'Citizen A',
          category: 'Pothole',
          description: 'Repaired pothole',
          latitude: 12.9716,
          longitude: 77.5946,
          address: 'Main St',
          status: 'resolved',
        ),
      ];

      final matches = duplicateService.findDuplicates(
        category: 'Pothole',
        latitude: 12.9716,
        longitude: 77.5946,
        activeComplaints: active,
      );

      expect(matches.isEmpty, true);
    });
  });

  group('CityPulse Role & User Tests', () {
    test('UserRole resolves accurately from string', () {
      expect(UserRole.fromString('citizen'), UserRole.citizen);
      expect(UserRole.fromString('officer'), UserRole.officer);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString(null), UserRole.citizen);
    });

    test('UserModel serialization and deserialization', () {
      final user = UserModel(
        uid: 'u123',
        name: 'Officer Alex',
        email: 'alex@gov.city',
        role: UserRole.officer,
        departmentId: 'dept_roads',
        badgeNumber: '9901',
      );

      final map = user.toMap();
      final reconstructed = UserModel.fromMap(map, id: 'u123');

      expect(reconstructed.uid, 'u123');
      expect(reconstructed.name, 'Officer Alex');
      expect(reconstructed.role, UserRole.officer);
      expect(reconstructed.badgeNumber, '9901');
    });
  });

  group('CityPulse Firestore Service Operations', () {
    final firestore = FirestoreService();

    test('Initial seeded complaints and departments exist', () async {
      final complaints = await firestore.getComplaints();
      final departments = await firestore.getDepartments();

      expect(complaints.isNotEmpty, true);
      expect(departments.length, 5);
      expect(complaints.any((c) => c.category == 'Pothole'), true);
    });

    test('Create, assign, and update status workflow', () async {
      final newComplaint = ComplaintModel(
        id: 'CP-TEST-99',
        citizenId: 'c101',
        citizenName: 'Citizen Tester',
        category: 'Traffic',
        description: 'Test traffic blockage at junction',
        latitude: 12.9716,
        longitude: 77.5946,
        address: 'Test Junction',
        status: 'submitted',
      );

      await firestore.createComplaint(newComplaint);
      final retrieved = await firestore.getComplaintById('CP-TEST-99');
      expect(retrieved != null, true);
      expect(retrieved!.status, 'submitted');

      // Update to assigned
      final assigned = retrieved.copyWith(
        status: 'assigned',
        departmentId: 'dept_traffic',
        departmentName: 'Traffic Management',
        officerId: 'officer_202',
        officerName: 'Marcus Vance',
      );
      await firestore.updateComplaint(assigned, changedBy: 'Director Lin', note: 'Assigned crew');

      final updated = await firestore.getComplaintById('CP-TEST-99');
      expect(updated!.status, 'assigned');
      expect(updated.officerName, 'Marcus Vance');

      // Check history
      final history = await firestore.getComplaintHistory('CP-TEST-99');
      expect(history.length, greaterThanOrEqualTo(2));
    });
  });
}
