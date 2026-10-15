import '../models/notification_model.dart';
import '../services/firestore_service.dart';

class NotificationRepository {
  final FirestoreService _firestoreService;

  NotificationRepository(this._firestoreService);

  Stream<List<NotificationModel>> streamNotifications(String userId) =>
      _firestoreService.streamNotifications(userId);

  Future<List<NotificationModel>> getNotifications(String userId) =>
      _firestoreService.getNotifications(userId);

  Future<void> markAsRead(String id) => _firestoreService.markNotificationAsRead(id);

  Future<void> markAllAsRead(String userId) => _firestoreService.markAllNotificationsAsRead(userId);

  Future<void> sendNotification(NotificationModel notif) =>
      _firestoreService.sendNotification(notif);
}
