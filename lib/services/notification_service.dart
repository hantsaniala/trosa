import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/models/trosa.dart';

/// Schedules local notifications for debt reminders.
///
/// Each debt can opt out, choose how many days before the due date to be
/// reminded, and the time of day. Overdue debts get a daily nag at the
/// configured reminder time until they are paid.
///
/// All platform calls are wrapped in try/catch so the service is a no-op in
/// environments without the plugins (e.g. widget tests).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

      const android = AndroidInitializationSettings('@mipmap/launcher_icon');
      const darwin = DarwinInitializationSettings();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: android,
          iOS: darwin,
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _initialized = true;
    } catch (_) {
      // Unsupported platform (or test environment): notifications disabled.
    }
  }

  /// Cancels all scheduled notifications and re-schedules them for every
  /// outstanding debt. Call on app start to stay in sync after edits.
  Future<void> rescheduleAll(String title, String Function(Trosa) bodyFor) async {
    try {
      await _ensureInitialized();
      final debts = await DatabaseProvider.db.getTrosa();
      await _plugin.cancelAll();
      for (final trosa in debts.where((t) => !t.isPaid)) {
        await _schedule(trosa, title, bodyFor);
      }
    } catch (_) {
      // Notifications are best-effort.
    }
  }

  Future<void> _schedule(
      Trosa trosa, String title, String Function(Trosa) bodyFor) async {
    final id = trosa.id;
    if (id == null || !trosa.reminderEnabled) return;

    final now = tz.TZDateTime.now(tz.local);
    final due = tz.TZDateTime(
      tz.local,
      trosa.dueDate.year,
      trosa.dueDate.month,
      trosa.dueDate.day,
    );

    if (due.isBefore(now)) {
      // Overdue: nag every day at the configured reminder time until paid.
      await _scheduleDaily(
          id, title, bodyFor(trosa), now, trosa.reminderTimeMinutes);
      return;
    }

    // Reminder fires reminderDaysBefore days before the due date, at the
    // configured time of day.
    final reminder = due
        .subtract(Duration(days: trosa.reminderDaysBefore))
        .add(Duration(minutes: trosa.reminderTimeMinutes));
    final scheduledDate = reminder.isBefore(now)
        ? now.add(const Duration(minutes: 5))
        : reminder;

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: bodyFor(trosa),
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Fampahatsiahivana trosa',
          channelDescription:
              'Fampahatsiahivana ny trosa tokony haloa na takiana.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  /// Schedules a notification that repeats daily at the reminder time while
  /// the debt stays overdue.
  Future<void> _scheduleDaily(int id, String title, String body,
      tz.TZDateTime now, int timeMinutes) async {
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        timeMinutes ~/ 60, timeMinutes % 60);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Fampahatsiahivana trosa',
          channelDescription:
              'Fampahatsiahivana ny trosa tokony haloa na takiana.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel(int id) async {
    try {
      await _ensureInitialized();
      await _plugin.cancel(id: id);
    } catch (_) {
      // Best-effort.
    }
  }
}
