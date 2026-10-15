import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import 'app_providers.dart';
import 'auth_provider.dart';

final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final authState = ref.watch(authProvider);
  final uid = authState.user?.uid ?? 'citizen_101';
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.streamNotifications(uid);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifsAsync = ref.watch(notificationsStreamProvider);
  return notifsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.read).length,
    orElse: () => 0,
  );
});
