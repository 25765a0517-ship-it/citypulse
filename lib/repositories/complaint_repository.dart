import 'dart:io';
import '../models/complaint_model.dart';
import '../models/complaint_history_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ComplaintRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  ComplaintRepository(this._firestoreService, this._storageService);

  Stream<List<ComplaintModel>> streamComplaints() => _firestoreService.streamComplaints();

  Future<List<ComplaintModel>> getComplaints() => _firestoreService.getComplaints();

  Future<ComplaintModel?> getComplaintById(String id) => _firestoreService.getComplaintById(id);

  Future<void> submitComplaint({
    required ComplaintModel complaint,
    List<File> imageFiles = const [],
  }) async {
    final uploadedUrls = <String>[];
    for (final file in imageFiles) {
      final url = await _storageService.uploadComplaintImage(
        complaintId: complaint.id,
        imageFile: file,
      );
      uploadedUrls.add(url);
    }

    final finalComplaint = complaint.copyWith(
      imageUrls: [...complaint.imageUrls, ...uploadedUrls],
    );

    await _firestoreService.createComplaint(finalComplaint);
  }

  Future<void> updateStatus({
    required String complaintId,
    required String status,
    required String changedBy,
    String? note,
  }) async {
    final complaint = await _firestoreService.getComplaintById(complaintId);
    if (complaint != null) {
      final updated = complaint.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await _firestoreService.updateComplaint(updated, changedBy: changedBy, note: note);
    }
  }

  Future<void> assignComplaint({
    required String complaintId,
    required String departmentId,
    required String departmentName,
    required String officerId,
    required String officerName,
    required String adminName,
  }) async {
    final complaint = await _firestoreService.getComplaintById(complaintId);
    if (complaint != null) {
      final updated = complaint.copyWith(
        departmentId: departmentId,
        departmentName: departmentName,
        officerId: officerId,
        officerName: officerName,
        status: 'assigned',
        updatedAt: DateTime.now(),
      );
      await _firestoreService.updateComplaint(
        updated,
        changedBy: adminName,
        note: 'Assigned to $departmentName ($officerName)',
      );
    }
  }

  Future<void> resolveComplaint({
    required String complaintId,
    required String officerName,
    required String resolutionNotes,
    File? resolutionPhoto,
  }) async {
    final complaint = await _firestoreService.getComplaintById(complaintId);
    if (complaint != null) {
      final resolutionUrls = <String>[];
      if (resolutionPhoto != null) {
        final url = await _storageService.uploadResolutionImage(
          complaintId: complaintId,
          imageFile: resolutionPhoto,
        );
        resolutionUrls.add(url);
      } else {
        resolutionUrls.add('assets/images/repaired_road.png');
      }

      final updated = complaint.copyWith(
        status: 'resolved',
        resolvedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        resolutionNotes: resolutionNotes,
        resolutionImageUrls: resolutionUrls,
      );

      await _firestoreService.updateComplaint(
        updated,
        changedBy: officerName,
        note: 'Work verified & completed: $resolutionNotes',
      );
    }
  }

  Future<void> supportComplaint(String id) => _firestoreService.supportComplaint(id);

  Future<List<ComplaintHistoryModel>> getTimeline(String complaintId) =>
      _firestoreService.getComplaintHistory(complaintId);
}
