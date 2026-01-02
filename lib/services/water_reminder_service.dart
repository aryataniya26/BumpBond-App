import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';

class WaterReminderService {
  static const String waterReminderTask = 'waterReminderTask';

  static Future<void> initialize() async {

    // Initialize Workmanager for background tasks
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
     // Cancel any existing water reminders
    await cancelWaterReminders();
    // Schedule new water reminders
    await scheduleWaterReminders();
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      print('💧 Background task: $task');

      if (task == waterReminderTask) {
        await NotificationService.sendWaterReminder();
        return true;
      }
      return Future.value(true);
    });
  }

  static Future<void> scheduleWaterReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('water_reminders_enabled') ?? true;

    if (!enabled) return;

    // Schedule reminders every 2 hours from 8 AM to 10 PM
    for (int hour = 8; hour <= 22; hour += 2) {
      await Workmanager().registerPeriodicTask(
        'water_reminder_$hour',
        waterReminderTask,
        frequency: const Duration(hours: 2),
        initialDelay: Duration(hours: hour),
        constraints: Constraints(
          // networkType: NetworkType.not_required,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
    }

    print('✅ Water reminders scheduled every 2 hours');
  }

  static Future<void> cancelWaterReminders() async {
    await Workmanager().cancelAll();
    print('✅ All water reminders cancelled');
  }

  static Future<void> setWaterRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('water_reminders_enabled', enabled);

    if (enabled) {
      await scheduleWaterReminders();
    } else {
      await cancelWaterReminders();
    }

    print('✅ Water reminders ${enabled ? 'enabled' : 'disabled'}');
  }

  static Future<bool> areWaterRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('water_reminders_enabled') ?? true;
  }
}
