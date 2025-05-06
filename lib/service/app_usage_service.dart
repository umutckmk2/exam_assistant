import 'package:flutter/foundation.dart';

import 'auth_service.dart';
import 'goals_service.dart';

class AppUsageService {
  static final AppUsageService _instance = AppUsageService._internal();
  AppUsageService._internal();
  static AppUsageService get instance => _instance;

  // The time when the app was last brought to the foreground
  DateTime? _appStartTime;

  // Start tracking app usage time
  void startTracking() {
    _appStartTime = DateTime.now();
    debugPrint(
      'Started tracking app usage at ${_appStartTime!.toIso8601String()}',
    );
  }

  // Stop tracking and save the usage time to the daily goal
  Future<void> stopTracking() async {
    if (_appStartTime == null) {
      return;
    }

    final now = DateTime.now();
    final elapsedTimeInMinutes = now.difference(_appStartTime!).inSeconds ~/ 60;

    debugPrint(
      'Stopping tracking app usage. Elapsed time: $elapsedTimeInMinutes minutes',
    );

    if (elapsedTimeInMinutes <= 0) {
      _appStartTime = null;
      return;
    }

    final userId = AuthService().currentUser?.uid;
    if (userId == null) {
      _appStartTime = null;
      return;
    }

    try {
      // Get today's goal
      final todayGoal = await GoalsService.instance.getTodayGoal(userId);

      // Update the pass time (time spent in app)
      todayGoal.passTime = (todayGoal.passTime ?? 0) + elapsedTimeInMinutes;

      // Save the updated goal
      await GoalsService.instance.saveTodayRecord(todayGoal);

      debugPrint(
        'Updated daily goal with $elapsedTimeInMinutes minutes of app usage',
      );
    } catch (e) {
      debugPrint('Error updating app usage time: $e');
    } finally {
      _appStartTime = null;
    }
  }
}
