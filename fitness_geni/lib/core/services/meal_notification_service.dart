import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;

import '../../features/home/domain/models/meal.dart';

/// Global navigation key — set from main.dart so notification taps can navigate.
/// This is a simple approach that avoids coupling to GoRouter internals.
typedef NotificationTapCallback = void Function();
NotificationTapCallback? onNotificationTapGlobal;

/// Smart Local Meal Reminder Service
///
/// Singleton service that manages daily meal reminder notifications.
///
/// **Lifecycle:**
/// 1. [initialize] — call once in main() before runApp
/// 2. [checkDailyResetAndEvaluate] — call on every app open (splash screen)
/// 3. [evaluateAndSchedule] — call whenever meal state changes
/// 4. [cancelAllNotifications] — call on logout
///
/// **Notification IDs:**
/// - 1 = Morning reminder (8:30 AM)
/// - 2 = Lunch reminder (2:15 PM)
/// - 3 = Dinner reminder (8:45 PM)
/// - 4 = Tomorrow morning fallback (8:30 AM +1 day)
///
/// **Safeguards:**
/// - Cancel-first pattern: [evaluateAndSchedule] always cancels IDs 1-4 before scheduling
/// - Time-passed validation: past-time notifications are never scheduled
/// - Fallback dedup: ID=4 is scheduled exactly once per evaluation cycle
/// - Boot receiver: Android-side only, does NOT run Dart evaluation
/// - All times use [tz.TZDateTime.now(tz.local)], never [DateTime.now()]
class MealNotificationService {
  MealNotificationService._();
  static final MealNotificationService instance = MealNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // SharedPreferences keys
  static const String _keyLastEvalDate = 'notif_last_eval_date';
  static const String _keyLastTimezone = 'notif_last_timezone';

  // Notification IDs — fixed, deterministic
  static const int _idMorning = 1;
  static const int _idLunch = 2;
  static const int _idDinner = 3;
  static const int _idTomorrowFallback = 4;

  // Notification channel
  static const String _channelId = 'meal_reminders';
  static const String _channelName = 'Meal Reminders';
  static const String _channelDescription =
      'Smart daily reminders for meal planning and tracking';

  bool _initialized = false;

  // ─────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────

  /// Initialize the notification plugin, timezone database, and Android channel.
  /// Must be called once in main() before runApp().
  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Initialize timezone database
    tz_data.initializeTimeZones();
    await _configureLocalTimezone();

    // 2. Initialize notification plugin
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // 3. Request permission (Android 13+ / iOS)
    await _requestPermission();

    _initialized = true;
    debugPrint('🔔 MealNotificationService: Initialized');
  }

  /// Detect and set the device timezone.
  Future<void> _configureLocalTimezone() async {
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
      debugPrint('🕐 Timezone configured: ${tzInfo.identifier}');
    } catch (e) {
      // Fallback to UTC if detection fails
      debugPrint('⚠️ Timezone detection failed, using UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// Request notification permission at runtime.
  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        debugPrint('🔔 Android notification permission: $granted');
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('🔔 iOS notification permission: $granted');
        return granted ?? false;
      }
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Daily Reset & Timezone Change
  // ─────────────────────────────────────────────────────────────────────────

  /// Check if a daily reset is needed (new day or timezone change).
  /// Call this on every app open (e.g., in splash screen after auth).
  ///
  /// Returns `true` if a reset was needed (caller should load meals then
  /// call [evaluateAndSchedule]).
  Future<bool> checkDailyResetNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayDateString();
    final lastDate = prefs.getString(_keyLastEvalDate);

    // Check timezone change
    final currentTz = await _getCurrentTimezone();
    final lastTz = prefs.getString(_keyLastTimezone);

    if (lastDate != today || lastTz != currentTz) {
      debugPrint(
        '🔔 Daily reset needed: lastDate=$lastDate today=$today '
        'lastTz=$lastTz currentTz=$currentTz',
      );

      // Reconfigure timezone if changed
      if (lastTz != currentTz) {
        await _configureLocalTimezone();
      }

      return true;
    }

    debugPrint('🔔 No daily reset needed (same day, same timezone)');
    return false;
  }

  Future<String> _getCurrentTimezone() async {
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      return tzInfo.identifier;
    } catch (_) {
      return 'UTC';
    }
  }

  String _todayDateString() {
    final now = tz.TZDateTime.now(tz.local);
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Core Scheduling Logic
  // ─────────────────────────────────────────────────────────────────────────

  /// Evaluate current meal state and schedule/cancel notifications accordingly.
  ///
  /// **Contract:**
  /// 1. Cancel ALL (IDs 1-4) — deterministic, no duplicates possible
  /// 2. Check current time — skip past-time windows
  /// 3. Check meal conditions — schedule only if condition met
  /// 4. Schedule tomorrow's morning fallback (ID=4) exactly once
  /// 5. Save lastEvaluationDate + timezone
  ///
  /// All times use [tz.TZDateTime.now(tz.local)].
  Future<void> evaluateAndSchedule(List<Meal> meals) async {
    if (!_initialized) {
      debugPrint('⚠️ MealNotificationService not initialized, skipping');
      return;
    }

    // Check permission before scheduling
    final hasPermission = await _hasNotificationPermission();
    if (!hasPermission) {
      debugPrint('⚠️ Notification permission denied, skipping scheduling');
      return;
    }

    // Step 1: Cancel ALL — deterministic dedup
    await cancelAllNotifications();
    debugPrint('🔔 evaluateAndSchedule: Cancelled all (IDs 1-4)');

    final now = tz.TZDateTime.now(tz.local);
    debugPrint(
      '🔔 evaluateAndSchedule: Current time=${now.hour}:${now.minute.toString().padLeft(2, '0')} '
      'meals=${meals.length}',
    );

    // Step 2+3: Time-check + condition-check for each window
    // ── Morning (8:30 AM): meals empty → remind to create
    if (_isBeforeTime(now, 8, 30)) {
      if (meals.isEmpty) {
        await _scheduleMorningReminder(now);
        debugPrint('🔔 Scheduled: Morning reminder (ID=$_idMorning)');
      } else {
        debugPrint('🔔 Skipped: Morning — meals already created');
      }
    } else {
      debugPrint('🔔 Skipped: Morning — time has passed');
    }

    // ── Lunch (2:15 PM): meals exist, "Afternoon" meal not done
    if (_isBeforeTime(now, 14, 15)) {
      if (meals.isNotEmpty) {
        final lunchMeal = _findMealByTime(meals, 'afternoon');
        if (lunchMeal != null && !lunchMeal.isDone) {
          await _scheduleLunchReminder(now);
          debugPrint('🔔 Scheduled: Lunch reminder (ID=$_idLunch)');
        } else {
          debugPrint('🔔 Skipped: Lunch — no lunch meal or already done');
        }
      } else {
        debugPrint('🔔 Skipped: Lunch — no meals created');
      }
    } else {
      debugPrint('🔔 Skipped: Lunch — time has passed');
    }

    // ── Dinner (8:45 PM): meals exist, "Night" meal not done
    if (_isBeforeTime(now, 20, 45)) {
      if (meals.isNotEmpty) {
        final dinnerMeal = _findMealByTime(meals, 'night');
        if (dinnerMeal != null && !dinnerMeal.isDone) {
          await _scheduleDinnerReminder(now);
          debugPrint('🔔 Scheduled: Dinner reminder (ID=$_idDinner)');
        } else {
          debugPrint('🔔 Skipped: Dinner — no dinner meal or already done');
        }
      } else {
        debugPrint('🔔 Skipped: Dinner — no meals created');
      }
    } else {
      debugPrint('🔔 Skipped: Dinner — time has passed');
    }

    // Step 4: Schedule tomorrow's morning fallback (ID=4) — exactly once
    await _scheduleTomorrowFallback(now);
    debugPrint(
      '🔔 Scheduled: Tomorrow morning fallback (ID=$_idTomorrowFallback)',
    );

    // Step 5: Save evaluation state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastEvalDate, _todayDateString());
    final currentTz = await _getCurrentTimezone();
    await prefs.setString(_keyLastTimezone, currentTz);
    debugPrint('🔔 evaluateAndSchedule: Complete. State saved.');
  }

  /// Cancel all notifications (IDs 1-4). Call on logout.
  Future<void> cancelAllNotifications() async {
    await _plugin.cancel(id: _idMorning);
    await _plugin.cancel(id: _idLunch);
    await _plugin.cancel(id: _idDinner);
    await _plugin.cancel(id: _idTomorrowFallback);
    debugPrint('🔔 cancelAllNotifications: Cancelled IDs 1, 2, 3, 4');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Individual Schedulers (private)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _scheduleMorningReminder(tz.TZDateTime now) async {
    final scheduledDate = _todayAt(now, 8, 30);
    await _scheduleNotification(
      id: _idMorning,
      title: 'Start Your Healthy Day 🌅',
      body:
          'You haven\'t planned your meals yet. Create today\'s meals to stay on track!',
      scheduledDate: scheduledDate,
      payload: 'morning_reminder',
    );
  }

  Future<void> _scheduleLunchReminder(tz.TZDateTime now) async {
    final scheduledDate = _todayAt(now, 14, 15);
    await _scheduleNotification(
      id: _idLunch,
      title: 'Lunch Reminder 🍽️',
      body: 'Your lunch is not marked as completed. Log it to stay consistent!',
      scheduledDate: scheduledDate,
      payload: 'lunch_reminder',
    );
  }

  Future<void> _scheduleDinnerReminder(tz.TZDateTime now) async {
    final scheduledDate = _todayAt(now, 20, 45);
    await _scheduleNotification(
      id: _idDinner,
      title: 'Dinner Reminder 🌙',
      body:
          'Your dinner is still pending. Complete it to maintain your streak!',
      scheduledDate: scheduledDate,
      payload: 'dinner_reminder',
    );
  }

  Future<void> _scheduleTomorrowFallback(tz.TZDateTime now) async {
    // Tomorrow at 8:30 AM — generic message
    final tomorrow = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + 1,
      8,
      30,
    );
    await _scheduleNotification(
      id: _idTomorrowFallback,
      title: 'Plan Your Day 📋',
      body: 'Don\'t forget to check your meals for today!',
      scheduledDate: tomorrow,
      payload: 'fallback_reminder',
    );
  }

  /// Core scheduling method — one-time, timezone-aware, no repeat.
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      debugPrint('❌ Failed to schedule notification ID=$id: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Check if current time is before the given hour:minute.
  bool _isBeforeTime(tz.TZDateTime now, int hour, int minute) {
    return now.hour < hour || (now.hour == hour && now.minute < minute);
  }

  /// Create a TZDateTime for today at the given hour:minute.
  tz.TZDateTime _todayAt(tz.TZDateTime now, int hour, int minute) {
    return tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  }

  /// Find a meal by its time slot (case-insensitive).
  /// Meal.time can be "Morning", "Afternoon", "Night", "morning", etc.
  Meal? _findMealByTime(List<Meal> meals, String timeSlot) {
    try {
      return meals.firstWhere(
        (m) => m.time.toLowerCase().contains(timeSlot.toLowerCase()),
      );
    } catch (_) {
      return null;
    }
  }

  /// Check if notification permission is currently granted.
  Future<bool> _hasNotificationPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.areNotificationsEnabled() ?? false;
      }
    }
    // On iOS, assume granted after initial request
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Notification Tap Handler
  // ─────────────────────────────────────────────────────────────────────────

  /// Called when user taps a notification. Navigates to Home.
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: payload=${response.payload}');
    // Invoke the global callback set in main.dart
    onNotificationTapGlobal?.call();
  }

  /// Clear stored evaluation state (for testing or reset).
  Future<void> clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastEvalDate);
    await prefs.remove(_keyLastTimezone);
    debugPrint('🔔 MealNotificationService: State cleared');
  }
}
