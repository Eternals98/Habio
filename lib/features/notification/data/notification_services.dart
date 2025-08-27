import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class LocalNotifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Canal
  static const String _channelId = 'habio_general';
  static const String _channelName = 'Habio';
  static const String _channelDesc = 'Recordatorios y avisos';

  // Reglas de IDs (determinísticos)
  static int _wheelIdForUid(String uid) => 10000 + (uid.hashCode & 0x3FFF);
  static int _habitDailyId(String habitId) =>
      20000 + (habitId.hashCode & 0x3FFF);
  static int _habitLastCallId(String habitId) =>
      30000 + (habitId.hashCode & 0x3FFF);

  // ---------------- Init ----------------
  static Future<void> init({
    // Si quieres abrir una ruta al tocar la noti, pásala en el payload cuando programes.
    void Function(String? payload)? onSelectNotification,
  }) async {
    // Time zone setup con fallback
    tzdata.initializeTimeZones();
    try {
      final String localTz = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC')); // fallback
    }

    // Icono Android: usa el mipmap del launcher por ahora
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // los pedimos luego explícitamente
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // iOS < 10 (poco común). Lo delegamos igual.
        onSelectNotification?.call(payload);
      },
    );

    await _plugin.initialize(
      InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (resp) {
        onSelectNotification?.call(resp.payload);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Crear canal Android (idempotente)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      showBadge: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // Handler de taps en background (Android)
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse resp) {
    // No tienes contexto aquí; solo deja registro o usa un mecanismo estático si te interesa.
  }

  // ---------------- Permisos ----------------
  static Future<void> requestPermissions() async {
    // Android 13+
    final androidImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImpl?.requestNotificationsPermission();

    // iOS
    final iosImpl =
        _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
    await iosImpl?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
      critical: false,
    );
  }

  // ---------------- Util ----------------
  static NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      styleInformation: BigTextStyleInformation(''),
    );
    const ios = DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
    );
    return const NotificationDetails(android: android, iOS: ios);
  }

  static tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static TimeOfDay? _tryParseHHmm(String s) {
    final p = s.split(':');
    if (p.length != 2) return null;
    final hh = int.tryParse(p[0]);
    final mm = int.tryParse(p[1]);
    if (hh == null || mm == null) return null;
    if (hh < 0 || hh > 23 || mm < 0 || mm > 59) return null;
    return TimeOfDay(hour: hh, minute: mm);
  }

  static List<TimeOfDay> _sanitizeTimes(List<String> times) {
    final parsed = <TimeOfDay>[];
    for (final s in times) {
      final t = _tryParseHHmm(s.trim());
      if (t != null) parsed.add(t);
    }
    // dedup y sort
    final set = {
      for (final t in parsed)
        '${t.hour}:${t.minute.toString().padLeft(2, '0')}',
    };
    final unique =
        set.map((s) => _tryParseHHmm(s)!).toList()
          ..sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
    return unique;
  }

  // Devuelve el próximo horario del array (hoy; si ya pasaron todos, retorna el primero para mañana).
  static TimeOfDay? _pickNextTimeOfDay(List<String> times) {
    final sanitized = _sanitizeTimes(times);
    if (sanitized.isEmpty) return null;
    final now = tz.TZDateTime.now(tz.local);
    for (final t in sanitized) {
      final candidate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        t.hour,
        t.minute,
      );
      if (candidate.isAfter(now)) return t;
    }
    return sanitized.first; // mañana
  }

  // ---------------- Ruleta diaria ----------------
  static Future<void> scheduleDailyWheelReminder({
    required String uid,
    TimeOfDay at = const TimeOfDay(hour: 9, minute: 0),
    String? payload, // ej. '/spin'
  }) async {
    final id = _wheelIdForUid(uid);
    await _plugin.zonedSchedule(
      id,
      '¡Tu giro diario está listo!',
      'Pasa por la ruleta y prueba suerte 🎡',
      _nextInstanceOf(at),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  static Future<void> cancelDailyWheelReminder(String uid) async {
    await _plugin.cancel(_wheelIdForUid(uid));
  }

  // ---------------- Hábitos ----------------
  static Future<void> scheduleNextHabitTime({
    required String habitId,
    required String habitName,
    required List<String> times,
    String? payload, // ej. '/room?id=XYZ&habit=$habitId'
  }) async {
    final next = _pickNextTimeOfDay(times);
    if (next == null) return;
    final id = _habitDailyId(habitId);
    await _plugin.zonedSchedule(
      id,
      'Recordatorio de hábito',
      'Toca completar “$habitName”',
      _nextInstanceOf(next),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Si ya tienes un DateTime exacto (por tu motor de calendario), usa este
  static Future<void> scheduleNextHabitAt({
    required String habitId,
    required String title,
    required String body,
    required DateTime atLocal,
    String? payload,
  }) async {
    final id = _habitDailyId(habitId);
    final tzAt = tz.TZDateTime.from(atLocal, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzAt,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> scheduleDailyHabitLastCall({
    required String habitId,
    required String habitName,
    TimeOfDay at = const TimeOfDay(hour: 21, minute: 30),
    String? payload,
  }) async {
    final id = _habitLastCallId(habitId);
    await _plugin.zonedSchedule(
      id,
      'Última llamada: $habitName',
      'Queda poco para que tu mascota pierda vida 🐾',
      _nextInstanceOf(at),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  static Future<void> cancelHabitNotifications(String habitId) async {
    await _plugin.cancel(_habitDailyId(habitId));
    await _plugin.cancel(_habitLastCallId(habitId));
  }

  static Future<void> cancelOnHabitDeath(String habitId) =>
      cancelHabitNotifications(habitId);

  static Future<void> cancelAll() => _plugin.cancelAll();

  // Helper: reprograma rápido usando solo los HH:mm del hábito
  static Future<void> reprogramHabitForToday({
    required String habitId,
    required String habitName,
    required List<String> times,
    TimeOfDay lastCallAt = const TimeOfDay(hour: 21, minute: 30),
    String? payload,
  }) async {
    await cancelHabitNotifications(habitId);
    await scheduleNextHabitTime(
      habitId: habitId,
      habitName: habitName,
      times: times,
      payload: payload,
    );
    await scheduleDailyHabitLastCall(
      habitId: habitId,
      habitName: habitName,
      at: lastCallAt,
      payload: payload,
    );
  }

  static FlutterLocalNotificationsPlugin get plugin => _plugin;
}
