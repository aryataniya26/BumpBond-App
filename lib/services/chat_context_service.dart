import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/pregnancy_data.dart';

class ChatContextService {
  Future<Map<String, dynamic>> getFullContext() async {
    final prefs = await SharedPreferences.getInstance();
    final pregnancyData = await PregnancyData.loadFromPrefs();

    return {
      'weekNumber': pregnancyData.currentWeekNumber,
      'dayNumber': pregnancyData.currentDayNumber,
      'trimester': pregnancyData.trimester,
      'babySize': pregnancyData.babySize,
      'recentMood': await _getRecentMood(prefs),
      'recentSymptoms': await _getRecentSymptoms(prefs),
      'lastMilestone': await _getLastMilestone(prefs),
      'medicationTaken': await _checkMedicationStatus(prefs),
      'lastJournalEntry': prefs.getString('last_journal_entry'),
      'waterIntakeToday': prefs.getInt('water_intake_${_getToday()}') ?? 0,
    };
  }

  Future<String> _getRecentMood(SharedPreferences prefs) async {
    final moodLogsJson = prefs.getString('mood_logs');
    if (moodLogsJson == null) return '';

    try {
      final List<dynamic> logs = jsonDecode(moodLogsJson);
      if (logs.isEmpty) return '';

      // Get most recent mood from today or yesterday
      final now = DateTime.now();
      final recentLogs = logs.where((log) {
        final logDate = DateTime.parse(log['date']);
        return now.difference(logDate).inHours < 24;
      }).toList();

      if (recentLogs.isEmpty) return '';

      final latestLog = recentLogs.last;
      return latestLog['mood'] ?? '';
    } catch (e) {
      return '';
    }
  }

  Future<List<String>> _getRecentSymptoms(SharedPreferences prefs) async {
    final symptomLogsJson = prefs.getString('symptom_logs');
    if (symptomLogsJson == null) return [];

    try {
      final List<dynamic> logs = jsonDecode(symptomLogsJson);
      if (logs.isEmpty) return [];

      // Get symptoms from last 24 hours
      final now = DateTime.now();
      final recentSymptoms = <String>[];

      for (var log in logs) {
        final logDate = DateTime.parse(log['date']);
        if (now.difference(logDate).inHours < 24) {
          final symptoms = log['symptoms'] as List?;
          if (symptoms != null) {
            recentSymptoms.addAll(symptoms.cast<String>());
          }
        }
      }

      return recentSymptoms.toSet().toList(); // Remove duplicates
    } catch (e) {
      return [];
    }
  }

  Future<String> _getLastMilestone(SharedPreferences prefs) async {
    final milestonesJson = prefs.getString('milestones');
    if (milestonesJson == null) return '';

    try {
      final List<dynamic> milestones = jsonDecode(milestonesJson);
      if (milestones.isEmpty) return '';

      // Get most recently completed milestone
      final completed = milestones.where((m) => m['completed'] == true).toList();
      if (completed.isEmpty) return '';

      completed.sort((a, b) {
        final dateA = DateTime.parse(a['completedDate']);
        final dateB = DateTime.parse(b['completedDate']);
        return dateB.compareTo(dateA);
      });

      final lastMilestone = completed.first;
      final completedDate = DateTime.parse(lastMilestone['completedDate']);

      // Only return if completed within last 3 days
      if (DateTime.now().difference(completedDate).inDays <= 3) {
        return lastMilestone['title'] ?? '';
      }

      return '';
    } catch (e) {
      return '';
    }
  }

  Future<bool> _checkMedicationStatus(SharedPreferences prefs) async {
    final medicationsJson = prefs.getString('medications');
    if (medicationsJson == null) return true;

    try {
      final List<dynamic> medications = jsonDecode(medicationsJson);
      if (medications.isEmpty) return true;

      final today = _getToday();
      final medicationLog = prefs.getString('medication_log_$today');

      if (medicationLog == null) {
        // Check if any medication time has passed today
        final now = DateTime.now();
        for (var med in medications) {
          final timeStr = med['time'] as String?;
          if (timeStr != null) {
            final medTime = DateFormat('HH:mm').parse(timeStr);
            final medDateTime = DateTime(now.year, now.month, now.day, medTime.hour, medTime.minute);

            if (now.isAfter(medDateTime)) {
              return false; // Medication time passed but not logged
            }
          }
        }
      }

      return true;
    } catch (e) {
      return true;
    }
  }

  String _getToday() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Helper methods to update context
  Future<void> recordDoctorAppointment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_doctor_appointment', DateTime.now().toIso8601String());
  }

  Future<void> recordJournalEntry() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_journal_entry', DateTime.now().toIso8601String());
  }

  Future<void> recordWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getToday();
    final currentIntake = prefs.getInt('water_intake_$today') ?? 0;
    await prefs.setInt('water_intake_$today', currentIntake + 1);
  }

  Future<void> recordMedicationTaken(String medicationName) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getToday();
    final log = prefs.getString('medication_log_$today') ?? '';
    final updated = log.isEmpty ? medicationName : '$log,$medicationName';
    await prefs.setString('medication_log_$today', updated);
  }
}