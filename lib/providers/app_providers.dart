import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/duplicate_detection_service.dart';
import '../services/priority_service.dart';
import '../services/routing_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/complaint_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/department_repository.dart';
import '../repositories/notification_repository.dart';

// Services
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final duplicateDetectionServiceProvider = Provider<DuplicateDetectionService>((ref) {
  return DuplicateDetectionService();
});

final priorityServiceProvider = Provider<PriorityService>((ref) {
  return PriorityService();
});

final routingServiceProvider = Provider<RoutingService>((ref) {
  return RoutingService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return AuthService(firestore);
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthRepository(authService);
});

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final storage = ref.watch(storageServiceProvider);
  return ComplaintRepository(firestore, storage);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return UserRepository(firestore);
});

final departmentRepositoryProvider = Provider<DepartmentRepository>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return DepartmentRepository(firestore);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return NotificationRepository(firestore);
});
