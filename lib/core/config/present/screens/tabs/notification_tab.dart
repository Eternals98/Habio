import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:per_habit/features/notification/data/notification_services.dart';

class NotificationsTab extends ConsumerStatefulWidget {
  const NotificationsTab({super.key});

  @override
  ConsumerState<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<NotificationsTab> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _payload = TextEditingController();

  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;
  bool _isDaily = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _payload.dispose();
    super.dispose();
  }

  NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      'habio_general', // mismo canal que en LocalNotifications
      'Habio',
      channelDescription: 'Recordatorios y avisos',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    ),
    iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
  );

  int _genId() {
    // ID estable y con baja prob. de colisión basada en título + modo
    final seed = '${_title.text.trim()}|${_isDaily ? "D" : "O"}';
    return 40000 + (seed.hashCode & 0x3FFF);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDate: _pickedDate ?? now,
    );
    if (res != null) setState(() => _pickedDate = res);
  }

  Future<void> _pickTime() async {
    final res = await showTimePicker(
      context: context,
      initialTime: _pickedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (res != null) setState(() => _pickedTime = res);
  }

  tz.TZDateTime _composeTzDateTime() {
    final now = tz.TZDateTime.now(tz.local);
    final d = _pickedDate ?? DateTime(now.year, now.month, now.day);
    final t = _pickedTime ?? const TimeOfDay(hour: 9, minute: 0);
    var scheduled = tz.TZDateTime(
      tz.local,
      d.year,
      d.month,
      d.day,
      t.hour,
      t.minute,
    );
    if (scheduled.isBefore(now)) {
      // si ya pasó, empuja a mañana
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _schedule() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    final payload = _payload.text.trim().isEmpty ? null : _payload.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título y cuerpo son obligatorios')),
      );
      return;
    }

    // Pedimos permisos por si el usuario no los dio aún
    await LocalNotifications.requestPermissions();

    final id = _genId();
    final at = _composeTzDateTime();

    if (_isDaily) {
      // Programación diaria a una hora fija
      await LocalNotifications.plugin.zonedSchedule(
        id,
        title,
        body,
        at,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } else {
      // One-shot
      await LocalNotifications.plugin.zonedSchedule(
        id,
        title,
        body,
        at,
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isDaily
              ? 'Notificación diaria programada a las ${_pickedTime?.format(context) ?? "hora seleccionada"}'
              : 'Notificación programada para ${at.hour.toString().padLeft(2, "0")}:${at.minute.toString().padLeft(2, "0")} ${at.day}/${at.month}',
        ),
      ),
    );
  }

  Future<void> _cancelAll() async {
    await LocalNotifications.cancelAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todas las notificaciones canceladas')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelLarge;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Programar notificaciones', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),

        TextField(
          controller: _title,
          decoration: const InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _body,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Cuerpo',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: _payload,
          decoration: const InputDecoration(
            labelText: 'Payload (opcional, p.ej. /spin o /room?id=XYZ)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _pickedDate == null
                      ? 'Elegir fecha'
                      : '${_pickedDate!.day}/${_pickedDate!.month}/${_pickedDate!.year}',
                  style: labelStyle,
                ),
                onPressed: _pickDate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.schedule),
                label: Text(
                  _pickedTime == null
                      ? 'Elegir hora'
                      : _pickedTime!.format(context),
                  style: labelStyle,
                ),
                onPressed: _pickTime,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        SwitchListTile.adaptive(
          value: _isDaily,
          onChanged: (v) => setState(() => _isDaily = v),
          title: const Text('Repetir todos los días a esta hora'),
          subtitle: const Text('Si está activo, se reprograma diariamente'),
        ),
        const SizedBox(height: 12),

        FilledButton.icon(
          icon: const Icon(Icons.notifications_active),
          onPressed: _schedule,
          label: const Text('Programar notificación'),
        ),
        const SizedBox(height: 8),

        OutlinedButton.icon(
          icon: const Icon(Icons.delete_sweep),
          onPressed: _cancelAll,
          label: const Text('Cancelar todas'),
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),

        Text('Tips', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text(
          '• Usa payload para abrir rutas (deep-link) cuando el usuario toca la notificación.\n'
          '• En pruebas en emulador, recuerda que a veces la zona horaria puede cambiar.',
        ),
      ],
    );
  }
}
