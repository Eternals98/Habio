// lib/features/game/pet/period_tracker.dart

enum PeriodChange { none, completed, missed }

class PeriodTracker {
  final String frequencyPeriod; // 'day' | 'week'
  final int frequencyCount;

  int doneInPeriod = 0;
  int failCount = 0; // 0..3
  String _periodKey = '';

  PeriodTracker({required this.frequencyPeriod, required this.frequencyCount});

  void initWith(DateTime now) {
    _periodKey = _currentPeriodKey(now);
  }

  void addCompletion() {
    doneInPeriod++;
    if (doneInPeriod >= frequencyCount) {
      failCount = 0; // éxito limpia faltas
    }
  }

  PeriodChange tick(DateTime now) {
    final key = _currentPeriodKey(now);
    if (_periodKey.isEmpty) {
      _periodKey = key;
      return PeriodChange.none;
    }
    if (key != _periodKey) {
      final missed = doneInPeriod < frequencyCount;
      if (missed) {
        failCount = (failCount + 1).clamp(0, 3);
        doneInPeriod = 0;
        _periodKey = key;
        return PeriodChange.missed;
      } else {
        failCount = 0;
        doneInPeriod = 0;
        _periodKey = key;
        return PeriodChange.completed;
      }
    }
    return PeriodChange.none;
  }

  String _currentPeriodKey(DateTime now) {
    if (frequencyPeriod == 'week') {
      final monday = now.subtract(Duration(days: (now.weekday + 6) % 7));
      final y = monday.year;
      final w =
          ((DateTime(y, 1, 4).difference(monday).inDays) / 7).abs().floor();
      return '$y-W$w';
    } else {
      return '${now.year}-${now.month}-${now.day}';
    }
  }
}
