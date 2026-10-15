import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/complaint_model.dart';
import '../models/complaint_history_model.dart';
import '../models/department_model.dart';
import '../models/notification_model.dart';
import 'firebase_service.dart';

class FirestoreService {
  // In-memory persistent state for offline / fallback / testing
  static final List<ComplaintModel> _localComplaints = [];
  static final List<ComplaintHistoryModel> _localHistory = [];
  static final List<DepartmentModel> _localDepartments = [];
  static final List<NotificationModel> _localNotifications = [];
  static final Map<String, UserModel> _localUsers = {};

  static final StreamController<List<ComplaintModel>> _complaintsStreamController =
      StreamController<List<ComplaintModel>>.broadcast();

  static final StreamController<List<NotificationModel>> _notificationsStreamController =
      StreamController<List<NotificationModel>>.broadcast();

  static bool _seeded = false;

  FirestoreService() {
    _seedInitialDataIfNeeded();
  }

  void _seedInitialDataIfNeeded() {
    if (_seeded) return;
    _seeded = true;

    // Seed test users
    final citizen = UserModel(
      uid: 'citizen_101',
      name: 'Citizen Alex',
      email: 'citizen@citypulse.gov',
      phone: '+1 (555) 234-5678',
      role: UserRole.citizen,
      ward: 'Ward 4 • Downtown North',
      avatarUrl: 'assets/images/citizen_avatar.png',
    );
    final officer = UserModel(
      uid: 'officer_202',
      name: 'Marcus Vance',
      email: 'officer@citypulse.gov',
      phone: '+1 (555) 876-5432',
      role: UserRole.officer,
      departmentId: 'dept_roads',
      departmentName: 'Roads & Infrastructure',
      badgeNumber: '4412',
      ward: 'Ward 4 • Downtown North',
      avatarUrl: 'assets/images/officer_avatar.png',
      availability: 'available',
    );
    final admin = UserModel(
      uid: 'admin_303',
      name: 'Director Sarah Lin',
      email: 'admin@citypulse.gov',
      phone: '+1 (555) 999-0000',
      role: UserRole.admin,
      ward: 'Metropolitan City HQ',
      avatarUrl: 'assets/images/citizen_avatar.png',
    );

    _localUsers[citizen.uid] = citizen;
    _localUsers[officer.uid] = officer;
    _localUsers[admin.uid] = admin;

    // Seed departments
    _localDepartments.addAll([
      DepartmentModel(
        id: 'dept_roads',
        name: 'Roads & Infrastructure',
        description: 'Pothole restoration, asphalt paving, road signs & pedestrian walkways',
        iconName: 'traffic',
        officerCount: 24,
        activeComplaints: 18,
        resolvedComplaints: 142,
      ),
      DepartmentModel(
        id: 'dept_waste',
        name: 'Waste Management',
        description: 'Municipal trash bin overflow, illegal dumping, street sweeping',
        iconName: 'delete',
        officerCount: 19,
        activeComplaints: 9,
        resolvedComplaints: 98,
      ),
      DepartmentModel(
        id: 'dept_water',
        name: 'Water & Utilities',
        description: 'Water main leaks, burst pipes, storm drains, hydrants',
        iconName: 'water_drop',
        officerCount: 16,
        activeComplaints: 12,
        resolvedComplaints: 87,
      ),
      DepartmentModel(
        id: 'dept_lighting',
        name: 'Street Lighting',
        description: 'Defective street lamps, blinking poles, electrical conduits',
        iconName: 'lightbulb',
        officerCount: 11,
        activeComplaints: 7,
        resolvedComplaints: 64,
      ),
      DepartmentModel(
        id: 'dept_traffic',
        name: 'Traffic Management',
        description: 'Signals, intersection gridlocks, pedestrian crossing signs',
        iconName: 'alt_route',
        officerCount: 15,
        activeComplaints: 5,
        resolvedComplaints: 53,
      ),
    ]);

    // Seed sample complaints
    final now = DateTime.now();
    final c1 = ComplaintModel(
      id: 'CP-88492',
      citizenId: 'citizen_101',
      citizenName: 'Citizen Alex',
      category: 'Pothole',
      description: 'Severe cracked road pothole near 5th cross road causing hazardous vehicle tire damage.',
      imageUrls: ['assets/images/pothole.png'],
      latitude: 12.9724,
      longitude: 77.5958,
      address: 'Near 5th Cross, 42nd Central Ave, Ward 4',
      status: 'assigned',
      priority: 'HIGH',
      departmentId: 'dept_roads',
      departmentName: 'Roads & Infrastructure',
      officerId: 'officer_202',
      officerName: 'Marcus Vance',
      supportCount: 5,
      createdAt: now.subtract(const Duration(hours: 4)),
      updatedAt: now.subtract(const Duration(hours: 2)),
    );

    final c2 = ComplaintModel(
      id: 'CP-88410',
      citizenId: 'citizen_101',
      citizenName: 'Citizen Alex',
      category: 'Streetlight',
      description: 'Streetlight pole #42 blinking erratically since yesterday evening creating dark blind spots.',
      imageUrls: ['assets/images/streetlight.png'],
      latitude: 12.9739,
      longitude: 77.5982,
      address: 'North Park Way, Ward 4',
      status: 'inProgress',
      priority: 'MEDIUM',
      departmentId: 'dept_lighting',
      departmentName: 'Street Lighting',
      officerId: 'officer_202',
      officerName: 'Marcus Vance',
      supportCount: 2,
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(hours: 1)),
    );

    final c3 = ComplaintModel(
      id: 'CP-88350',
      citizenId: 'citizen_101',
      citizenName: 'Citizen Alex',
      category: 'Garbage',
      description: 'Public municipal green dumpster overflowing into pedestrian pavement.',
      imageUrls: ['assets/images/garbage.png'],
      latitude: 12.9701,
      longitude: 77.5921,
      address: 'Market Square Corner, Ward 4',
      status: 'resolved',
      priority: 'LOW',
      departmentId: 'dept_waste',
      departmentName: 'Waste Management',
      officerId: 'officer_202',
      officerName: 'Marcus Vance',
      supportCount: 8,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(hours: 5)),
      resolvedAt: now.subtract(const Duration(hours: 5)),
      resolutionImageUrls: ['assets/images/repaired_road.png'],
      resolutionNotes: 'Site completely cleared and sanitized by Sanitation Crew #3.',
    );

    final c4 = ComplaintModel(
      id: 'CP-88299',
      citizenId: 'citizen_101',
      citizenName: 'Citizen Alex',
      category: 'Water Leakage',
      description: 'Major underground pipe breach leaking high volume freshwater onto asphalt.',
      imageUrls: ['assets/images/water_leakage.png'],
      latitude: 12.9745,
      longitude: 77.5910,
      address: '77th Industrial Ring Road, Ward 4',
      status: 'submitted',
      priority: 'CRITICAL',
      departmentId: 'dept_water',
      departmentName: 'Water & Utilities',
      supportCount: 11,
      createdAt: now.subtract(const Duration(minutes: 45)),
      updatedAt: now.subtract(const Duration(minutes: 45)),
    );

    _localComplaints.addAll([c1, c2, c3, c4]);

    // Seed complaint history
    _localHistory.addAll([
      ComplaintHistoryModel(
        id: 'hist_1',
        complaintId: 'CP-88492',
        status: 'submitted',
        changedBy: 'Citizen Alex',
        message: 'Complaint submitted with GPS coordinates and photo evidence',
        timestamp: now.subtract(const Duration(hours: 4)),
      ),
      ComplaintHistoryModel(
        id: 'hist_2',
        complaintId: 'CP-88492',
        status: 'verified',
        changedBy: 'Admin Dispatch System',
        message: 'Verified location and classified priority as HIGH based on road arterial impact',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      ComplaintHistoryModel(
        id: 'hist_3',
        complaintId: 'CP-88492',
        status: 'assigned',
        changedBy: 'Director Sarah Lin',
        message: 'Assigned to Roads & Infrastructure department • Officer Marcus Vance',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
    ]);

    // Seed notifications
    _localNotifications.addAll([
      NotificationModel(
        id: 'notif_1',
        userId: 'citizen_101',
        title: 'Officer Assigned to Report #CP-88492',
        message: 'Officer Marcus Vance from Roads & Infrastructure has been dispatched.',
        type: 'officerAssigned',
        complaintId: 'CP-88492',
        read: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'notif_2',
        userId: 'citizen_101',
        title: 'Report #CP-88350 Resolved',
        message: 'Market Square dumpster cleanup completed. View the resolution photo.',
        type: 'complaintResolved',
        complaintId: 'CP-88350',
        read: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'notif_3',
        userId: 'officer_202',
        title: 'New Urgent Assignment #CP-88492',
        message: 'You have been assigned a High Priority Pothole on 42nd Central Ave.',
        type: 'officerAssigned',
        complaintId: 'CP-88492',
        read: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ]);

    _emitStreams();
  }

  static void _emitStreams() {
    _complaintsStreamController.add(List.unmodifiable(_localComplaints));
    _notificationsStreamController.add(List.unmodifiable(_localNotifications));
  }

  // --- USER OPERATIONS ---
  Future<UserModel?> getUser(String uid) async {
    try {
      if (FirebaseService.isInitialized) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, id: doc.id);
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getUser error: $e');
    }
    return _localUsers[uid];
  }

  Future<void> saveUser(UserModel user) async {
    _localUsers[user.uid] = user;
    try {
      if (FirebaseService.isInitialized) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(user.toMap());
      }
    } catch (e) {
      debugPrint('[FirestoreService] saveUser error: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      if (FirebaseService.isInitialized) {
        final snap = await FirebaseFirestore.instance.collection('users').get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => UserModel.fromMap(d.data(), id: d.id)).toList();
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getAllUsers error: $e');
    }
    return _localUsers.values.toList();
  }

  Future<List<UserModel>> getOfficersByDepartment(String departmentId) async {
    final all = await getAllUsers();
    return all.where((u) => u.role == UserRole.officer && (u.departmentId == departmentId || u.departmentId == null)).toList();
  }

  // --- COMPLAINTS OPERATIONS ---
  Stream<List<ComplaintModel>> streamComplaints() {
    if (FirebaseService.isInitialized) {
      return FirebaseFirestore.instance
          .collection('complaints')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => ComplaintModel.fromMap(d.data(), id: d.id)).toList());
    }
    return _complaintsStreamController.stream;
  }

  Future<List<ComplaintModel>> getComplaints() async {
    try {
      if (FirebaseService.isInitialized) {
        final snap = await FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('createdAt', descending: true)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => ComplaintModel.fromMap(d.data(), id: d.id)).toList();
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getComplaints error: $e');
    }
    return List.unmodifiable(_localComplaints);
  }

  Future<ComplaintModel?> getComplaintById(String id) async {
    try {
      if (FirebaseService.isInitialized) {
        final doc = await FirebaseFirestore.instance.collection('complaints').doc(id).get();
        if (doc.exists && doc.data() != null) {
          return ComplaintModel.fromMap(doc.data()!, id: doc.id);
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getComplaintById error: $e');
    }
    try {
      return _localComplaints.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> createComplaint(ComplaintModel complaint) async {
    _localComplaints.insert(0, complaint);

    // Automatically create initial audit history
    final history = ComplaintHistoryModel(
      id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
      complaintId: complaint.id,
      status: 'submitted',
      changedBy: complaint.citizenName,
      message: 'Citizen created report #${complaint.id} for ${complaint.category}',
      timestamp: DateTime.now(),
    );
    _localHistory.add(history);

    // Create confirmation notification
    final notif = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: complaint.citizenId,
      title: 'Report #${complaint.id} Received',
      message: 'Your ${complaint.category} report has been filed and routed for municipal verification.',
      type: 'complaintSubmitted',
      complaintId: complaint.id,
      read: false,
    );
    _localNotifications.insert(0, notif);

    _emitStreams();

    try {
      if (FirebaseService.isInitialized) {
        final batch = FirebaseFirestore.instance.batch();
        final complaintRef = FirebaseFirestore.instance.collection('complaints').doc(complaint.id);
        final histRef = FirebaseFirestore.instance.collection('complaint_history').doc(history.id);
        final notifRef = FirebaseFirestore.instance.collection('notifications').doc(notif.id);

        batch.set(complaintRef, complaint.toMap());
        batch.set(histRef, history.toMap());
        batch.set(notifRef, notif.toMap());
        await batch.commit();
      }
    } catch (e) {
      debugPrint('[FirestoreService] createComplaint error: $e');
    }
  }

  Future<void> updateComplaint(ComplaintModel complaint, {String? changedBy, String? note}) async {
    final index = _localComplaints.indexWhere((c) => c.id == complaint.id);
    if (index != -1) {
      _localComplaints[index] = complaint;
    } else {
      _localComplaints.add(complaint);
    }

    if (note != null || changedBy != null) {
      final history = ComplaintHistoryModel(
        id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
        complaintId: complaint.id,
        status: complaint.status,
        changedBy: changedBy ?? 'System',
        message: note ?? 'Status updated to ${complaint.status}',
        timestamp: DateTime.now(),
      );
      _localHistory.add(history);
    }

    _emitStreams();

    try {
      if (FirebaseService.isInitialized) {
        await FirebaseFirestore.instance.collection('complaints').doc(complaint.id).update(complaint.toMap());
      }
    } catch (e) {
      debugPrint('[FirestoreService] updateComplaint error: $e');
    }
  }

  Future<void> supportComplaint(String complaintId) async {
    final index = _localComplaints.indexWhere((c) => c.id == complaintId);
    if (index != -1) {
      final current = _localComplaints[index];
      _localComplaints[index] = current.copyWith(supportCount: current.supportCount + 1);
      _emitStreams();
    }
  }

  // --- COMPLAINT HISTORY ---
  Future<List<ComplaintHistoryModel>> getComplaintHistory(String complaintId) async {
    try {
      if (FirebaseService.isInitialized) {
        final snap = await FirebaseFirestore.instance
            .collection('complaint_history')
            .where('complaintId', isEqualTo: complaintId)
            .orderBy('timestamp', descending: false)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => ComplaintHistoryModel.fromMap(d.data(), id: d.id)).toList();
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getComplaintHistory error: $e');
    }
    return _localHistory.where((h) => h.complaintId == complaintId).toList();
  }

  // --- DEPARTMENTS ---
  Future<List<DepartmentModel>> getDepartments() async {
    try {
      if (FirebaseService.isInitialized) {
        final snap = await FirebaseFirestore.instance.collection('departments').get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => DepartmentModel.fromMap(d.data(), id: d.id)).toList();
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getDepartments error: $e');
    }
    return List.unmodifiable(_localDepartments);
  }

  // --- NOTIFICATIONS ---
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    if (FirebaseService.isInitialized) {
      return FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => NotificationModel.fromMap(d.data(), id: d.id)).toList());
    }
    return _notificationsStreamController.stream.map(
      (list) => list.where((n) => n.userId == userId).toList(),
    );
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      if (FirebaseService.isInitialized) {
        final snap = await FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs.map((d) => NotificationModel.fromMap(d.data(), id: d.id)).toList();
        }
      }
    } catch (e) {
      debugPrint('[FirestoreService] getNotifications error: $e');
    }
    return _localNotifications.where((n) => n.userId == userId).toList();
  }

  Future<void> markNotificationAsRead(String notifId) async {
    final idx = _localNotifications.indexWhere((n) => n.id == notifId);
    if (idx != -1) {
      _localNotifications[idx] = _localNotifications[idx].copyWith(read: true);
      _emitStreams();
    }
    try {
      if (FirebaseService.isInitialized) {
        await FirebaseFirestore.instance.collection('notifications').doc(notifId).update({'read': true});
      }
    } catch (e) {
      debugPrint('[FirestoreService] markNotificationAsRead error: $e');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    for (int i = 0; i < _localNotifications.length; i++) {
      if (_localNotifications[i].userId == userId) {
        _localNotifications[i] = _localNotifications[i].copyWith(read: true);
      }
    }
    _emitStreams();
  }

  Future<void> sendNotification(NotificationModel notif) async {
    _localNotifications.insert(0, notif);
    _emitStreams();
    try {
      if (FirebaseService.isInitialized) {
        await FirebaseFirestore.instance.collection('notifications').doc(notif.id).set(notif.toMap());
      }
    } catch (e) {
      debugPrint('[FirestoreService] sendNotification error: $e');
    }
  }
}
