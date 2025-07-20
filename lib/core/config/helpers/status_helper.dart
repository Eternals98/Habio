import 'package:per_habit/core/config/models/status_model.dart';

class StatusHelper {
  static String getBaseStatusFromLife({
    required List<StatusModel> statuses,
    required int life,
  }) {
    final coreStatuses = statuses.where((s) => s.type == 'core');

    for (final status in coreStatuses) {
      final min = status.minLife ?? 0;
      final max = status.maxLife ?? 100;

      if (life >= min && life <= max) {
        return status.id;
      }
    }

    return 'unknown'; // fallback si no encuentra ninguno
  }
}
