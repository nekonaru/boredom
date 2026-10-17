import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Daily reminder notifications.
///
/// Only used when the user turns reminders on in Profile; nothing is
/// scheduled by default. All calls are best effort: any failure is logged
/// and swallowed, because notifications are a convenience, never a
/// blocker for the rest of the app.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  static const int _dailyId = 1001;
  static const String _channelId = 'boredom_daily';
  static const String _channelName = 'Daily reminder';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  /// Initializes the plugin and the timezone database. Safe to call more
  /// than once. Skipped in tests, where no platform channel exists.
  Future<void> init() async {
    if (_ready) return;
    try {
      tz.initializeTimeZones();
      // Without a platform channel (tests, desktop) this throws, and the
      // local timezone stays UTC, which is harmless for scheduling.
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        // Keep the default UTC location.
      }

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher_foreground'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings: settings);
      _ready = true;
    } catch (e) {
      debugPrint('ReminderService init failed: $e');
    }
  }

  Future<bool> requestPermission() async {
    await init();
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return false;
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    } catch (e) {
      debugPrint('ReminderService permission request failed: $e');
      return false;
    }
  }

  /// Schedules (or reschedules) one repeating daily reminder.
  Future<void> scheduleDaily(int hour, int minute) async {
    await init();
    try {
      await _plugin.zonedSchedule(
        id: _dailyId,
        title: 'Boredom',
        body: 'You are bored. So... what now?',
        scheduledDate: _nextInstanceOf(hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: 'Daily reminder to roll a new mission',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('ReminderService schedule failed: $e');
    }
  }

  Future<void> cancelDaily() async {
    try {
      await _plugin.cancel(id: _dailyId);
    } catch (e) {
      debugPrint('ReminderService cancel failed: $e');
    }
  }

  /// True when notifications are currently allowed for the app.
  Future<bool> permissionGranted() async {
    await init();
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? false;
    } catch (e) {
      debugPrint('ReminderService permission check failed: $e');
      return false;
    }
  }

  /// Next occurrence of [hour]:[minute] in the local timezone.
  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}