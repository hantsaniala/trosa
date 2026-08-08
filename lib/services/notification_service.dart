import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:trosa/db/sqflite_provider.dart';
import 'package:trosa/models/trosa.dart';

/// Schedules a local notification one day before a debt's due date.
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
    if (id == null) return;

    // Remind one day before the due date (or today if due sooner).
    var reminder = trosa.dueDate.subtract(const Duration(days: 1));
    final now = DateTime.now();
    if (reminder.isBefore(now)) {
      reminder = now.add(const Duration(minutes: 5));
    }

    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(reminder, tz.local),
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
      title: title,
      body: bodyFor(trosa),
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
