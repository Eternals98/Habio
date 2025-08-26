import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:per_habit/features/notification/domain/entity/notificacion.dart';
import 'package:uuid/uuid.dart';

class NotificationsController extends StateNotifier<List<NotificationItem>> {
  NotificationsController() : super(const []);

  final _uuid = const Uuid();

  void add({required String title, required String body}) {
    final n = NotificationItem(
      id: _uuid.v4(),
      title: title,
      body: body,
      createdAt: DateTime.now(),
      read: false,
    );
    state = [n, ...state]; // arriba primero
  }

  void markAllRead() {
    state = [
      for (final n in state)
        NotificationItem(
          id: n.id,
          title: n.title,
          body: n.body,
          createdAt: n.createdAt,
          read: true,
        ),
    ];
  }

  void remove(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clear() {
    state = const [];
  }
}

final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, List<NotificationItem>>(
      (ref) => NotificationsController(),
    );

final unreadCountProvider = Provider<int>((ref) {
  final all = ref.watch(notificationsControllerProvider);
  return all.where((n) => !n.read).length;
});
