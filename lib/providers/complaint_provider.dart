import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import '../models/complaint_model.dart';
import '../models/complaint_history_model.dart';
import '../repositories/complaint_repository.dart';
import '../services/duplicate_detection_service.dart';
import '../services/priority_service.dart';
import 'app_providers.dart';

class ComplaintDraft {
  String category;
  List<File> photos;
  String description;
  double latitude;
  double longitude;
  String address;
  String calculatedPriority;
  String priorityReason;
  int severityScore;
  bool isAnonymous;

  ComplaintDraft({
    this.category = 'Pothole',
    this.photos = const [],
    this.description = '',
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.address = 'Ward 4 • Downtown North',
    this.calculatedPriority = 'MEDIUM',
    this.priorityReason = 'Standard assessment',
    this.severityScore = 50,
    this.isAnonymous = false,
  });

  ComplaintDraft copyWith({
    String? category,
    List<File>? photos,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? calculatedPriority,
    String? priorityReason,
    int? severityScore,
    bool? isAnonymous,
  }) {
    return ComplaintDraft(
      category: category ?? this.category,
      photos: photos ?? this.photos,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      calculatedPriority: calculatedPriority ?? this.calculatedPriority,
      priorityReason: priorityReason ?? this.priorityReason,
      severityScore: severityScore ?? this.severityScore,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}

class ComplaintState {
  final List<ComplaintModel> allComplaints;
  final bool isLoading;
  final String? errorMessage;
  final ComplaintDraft draft;
  final List<DuplicateMatch> detectedDuplicates;

  ComplaintState({
    this.allComplaints = const [],
    this.isLoading = false,
    this.errorMessage,
    ComplaintDraft? draft,
    this.detectedDuplicates = const [],
  }) : draft = draft ?? ComplaintDraft();

  ComplaintState copyWith({
    List<ComplaintModel>? allComplaints,
    bool? isLoading,
    String? errorMessage,
    ComplaintDraft? draft,
    List<DuplicateMatch>? detectedDuplicates,
    bool clearError = false,
  }) {
    return ComplaintState(
      allComplaints: allComplaints ?? this.allComplaints,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      draft: draft ?? this.draft,
      detectedDuplicates: detectedDuplicates ?? this.detectedDuplicates,
    );
  }
}

class ComplaintNotifier extends StateNotifier<ComplaintState> {
  final ComplaintRepository _repository;
  final DuplicateDetectionService _duplicateService;
  final PriorityService _priorityService;

  ComplaintNotifier(this._repository, this._duplicateService, this._priorityService)
      : super(ComplaintState()) {
    loadComplaints();
    _listenToComplaints();
  }

  void _listenToComplaints() {
    _repository.streamComplaints().listen((list) {
      state = state.copyWith(allComplaints: list);
    });
  }

  Future<void> loadComplaints() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getComplaints();
      state = state.copyWith(allComplaints: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // --- REPORT WIZARD STEPS ---
  void updateDraftCategory(String category) {
    state = state.copyWith(draft: state.draft.copyWith(category: category));
    _recalculatePriorityAndDuplicates();
  }

  void addDraftPhoto(File photo) {
    final updated = List<File>.from(state.draft.photos)..add(photo);
    state = state.copyWith(draft: state.draft.copyWith(photos: updated));
  }

  void removeDraftPhoto(int index) {
    if (index >= 0 && index < state.draft.photos.length) {
      final updated = List<File>.from(state.draft.photos)..removeAt(index);
      state = state.copyWith(draft: state.draft.copyWith(photos: updated));
    }
  }

  void updateDraftDescription(String text) {
    state = state.copyWith(draft: state.draft.copyWith(description: text));
    _recalculatePriorityAndDuplicates();
  }

  void updateDraftLocation({required double lat, required double lng, required String address}) {
    state = state.copyWith(draft: state.draft.copyWith(latitude: lat, longitude: lng, address: address));
    _recalculatePriorityAndDuplicates();
  }

  void _recalculatePriorityAndDuplicates() {
    final duplicates = _duplicateService.findDuplicates(
      category: state.draft.category,
      latitude: state.draft.latitude,
      longitude: state.draft.longitude,
      activeComplaints: state.allComplaints,
    );

    final assessment = _priorityService.calculatePriority(
      category: state.draft.category,
      description: state.draft.description,
      nearbyReportsCount: duplicates.length,
    );

    state = state.copyWith(
      detectedDuplicates: duplicates,
      draft: state.draft.copyWith(
        calculatedPriority: assessment.priority,
        priorityReason: assessment.reason,
        severityScore: assessment.severityScore,
      ),
    );
  }

  Future<String> submitCurrentDraft({
    required String citizenId,
    required String citizenName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final ticketNumber = (DateTime.now().millisecondsSinceEpoch % 90000 + 10000).toString();
      final complaintId = 'CP-$ticketNumber';

      // Pick representative asset image if no camera/gallery file was chosen
      List<String> defaultAssets = [];
      switch (state.draft.category.toLowerCase()) {
        case 'pothole':
          defaultAssets = ['assets/images/pothole.png'];
          break;
        case 'streetlight':
          defaultAssets = ['assets/images/streetlight.png'];
          break;
        case 'garbage':
          defaultAssets = ['assets/images/garbage.png'];
          break;
        case 'water leakage':
          defaultAssets = ['assets/images/water_leakage.png'];
          break;
        default:
          defaultAssets = ['assets/images/pothole.png'];
      }

      final newComplaint = ComplaintModel(
        id: complaintId,
        citizenId: citizenId,
        citizenName: state.draft.isAnonymous ? 'Anonymous Citizen' : citizenName,
        category: state.draft.category,
        description: state.draft.description.isEmpty
            ? '${state.draft.category} issue reported at ${state.draft.address}'
            : state.draft.description,
        imageUrls: defaultAssets,
        latitude: state.draft.latitude,
        longitude: state.draft.longitude,
        address: state.draft.address,
        status: 'submitted',
        priority: state.draft.calculatedPriority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.submitComplaint(
        complaint: newComplaint,
        imageFiles: state.draft.photos,
      );

      // Reset draft
      state = state.copyWith(
        isLoading: false,
        draft: ComplaintDraft(),
        detectedDuplicates: [],
      );

      return complaintId;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  // --- ACTIONS ---
  Future<void> supportComplaint(String id) async {
    await _repository.supportComplaint(id);
  }

  Future<void> assignDepartmentAndOfficer({
    required String complaintId,
    required String departmentId,
    required String departmentName,
    required String officerId,
    required String officerName,
    required String adminName,
  }) async {
    await _repository.assignComplaint(
      complaintId: complaintId,
      departmentId: departmentId,
      departmentName: departmentName,
      officerId: officerId,
      officerName: officerName,
      adminName: adminName,
    );
  }

  Future<void> updateStatus({
    required String complaintId,
    required String status,
    required String changedBy,
    String? note,
  }) async {
    await _repository.updateStatus(
      complaintId: complaintId,
      status: status,
      changedBy: changedBy,
      note: note,
    );
  }

  Future<void> resolveComplaint({
    required String complaintId,
    required String officerName,
    required String resolutionNotes,
    File? resolutionPhoto,
  }) async {
    await _repository.resolveComplaint(
      complaintId: complaintId,
      officerName: officerName,
      resolutionNotes: resolutionNotes,
      resolutionPhoto: resolutionPhoto,
    );
  }

  Future<List<ComplaintHistoryModel>> getTimeline(String complaintId) =>
      _repository.getTimeline(complaintId);
}

final complaintProvider = StateNotifierProvider<ComplaintNotifier, ComplaintState>((ref) {
  final repo = ref.watch(complaintRepositoryProvider);
  final dup = ref.watch(duplicateDetectionServiceProvider);
  final pri = ref.watch(priorityServiceProvider);
  return ComplaintNotifier(repo, dup, pri);
});
