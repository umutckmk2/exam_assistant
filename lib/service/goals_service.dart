import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../model/daily_goal.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class GoalsService {
  static final GoalsService _instance = GoalsService._internal();

  GoalsService._internal();

  late Box<Map> _dailyGoalRecords;

  static GoalsService get instance => _instance;

  static final todayMidNightAsSeconds =
      DateTime.now()
          .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0)
          .millisecondsSinceEpoch ~/
      1000;

  final settingsBox = Hive.box("settings");

  Future<void> _openBox() async {
    if (Hive.isBoxOpen("dailyGoalRecords")) {
      _dailyGoalRecords = Hive.box<Map>("dailyGoalRecords");
    } else {
      _dailyGoalRecords = await Hive.openBox<Map>("dailyGoalRecords");
    }
  }

  Future<void> setDailyGoal(DailyGoal goal) async {
    final userId = AuthService().currentUser?.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'dailyGoalSettings': goal.toJson(),
    });
    await settingsBox.put("dailyGoalSettings", goal.toJson());

    final todayGoal = await getTodayGoal();
    final updatedTodayGoal = {
      ...todayGoal.toJson(),
      'dailyQuestionGoal': goal.dailyQuestionGoal,
      'notifyTime': {
        'hour': goal.notifyTime.hour,
        'minute': goal.notifyTime.minute,
      },
    };

    await FirebaseDatabase.instance
        .ref('users/$userId/goals/daily/$todayMidNightAsSeconds')
        .set(updatedTodayGoal);

    // Schedule notification based on the set goal
    await NotificationService().scheduleDailyGoalReminder(
      DailyGoal.fromJson(updatedTodayGoal),
    );
  }

  Future<DailyGoal> saveTodayRecord(DailyGoal goal) async {
    await _openBox();
    final userId = AuthService().currentUser?.uid;

    await _dailyGoalRecords.put(todayMidNightAsSeconds, goal.toJson());
    await FirebaseDatabase.instance
        .ref('users/$userId/goals/daily/$todayMidNightAsSeconds')
        .set({...goal.toJson()});
    return goal;
  }

  Future<void> saveMissingRecords() async {
    await _openBox();
    try {
      final userId = AuthService().currentUser?.uid;
      final dailyGoalSettings = getDailyGoalSettings();

      // Get today and Monday timestamps
      final today = DateTime.fromMillisecondsSinceEpoch(
        todayMidNightAsSeconds * 1000,
      );
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final mondayTimestamp = monday.millisecondsSinceEpoch ~/ 1000;

      // Get this week's records from Firebase
      final weekRecordsSnapshot =
          await FirebaseDatabase.instance
              .ref('users/$userId/goals/daily')
              .orderByKey()
              .startAt(mondayTimestamp.toString())
              .endAt(todayMidNightAsSeconds.toString())
              .get();

      final data = weekRecordsSnapshot.value as Map?;

      if (data == null || data.isEmpty) {
        // If no records exist, save today's record
        await saveTodayRecord(dailyGoalSettings);
        return;
      }

      // Save records to local box
      for (final entry in data.entries) {
        final timestamp = int.parse(entry.key);
        final recordMap = entry.value as Map;
        await _dailyGoalRecords.put(timestamp, recordMap);
      }

      // If today's record doesn't exist, create it
      if (!data.containsKey(todayMidNightAsSeconds.toString())) {
        await saveTodayRecord(dailyGoalSettings);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> saveDailyGoalSettings(String userId, DailyGoal goal) async {
    await _openBox();
    await _dailyGoalRecords.put(todayMidNightAsSeconds, goal.toJson());
    await FirebaseDatabase.instance
        .ref('users/$userId/goals/daily/$todayMidNightAsSeconds')
        .set({...goal.toJson()});
  }

  Future<Map<String, DailyGoal>> getThisWeekGoalRecords(String userId) async {
    await _openBox();
    final dailyGoalSettings = getDailyGoalSettings();
    final thisWeekDatesAsSeconds = <int>[];
    final startOfToday = DateTime.fromMillisecondsSinceEpoch(
      todayMidNightAsSeconds * 1000,
    );
    final endOfWeek = startOfToday.add(
      Duration(days: 7 - startOfToday.weekday),
    );

    final startOfWeek = startOfToday.subtract(
      Duration(days: startOfToday.weekday - 1),
    );

    for (var i = 0; i <= endOfWeek.difference(startOfWeek).inDays; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final timestamp = date.millisecondsSinceEpoch ~/ 1000;
      thisWeekDatesAsSeconds.add(timestamp);
    }

    final thisWeekRecords = <String, DailyGoal>{};
    for (final timestamp in thisWeekDatesAsSeconds) {
      final record = _dailyGoalRecords.get(timestamp);

      thisWeekRecords[timestamp.toString()] = DailyGoal.fromJson(
        record ?? dailyGoalSettings.toJson(),
      );
    }

    return thisWeekRecords;
  }

  Future<DailyGoal> getTodayGoal() async {
    await _openBox();
    final today = todayMidNightAsSeconds;
    final record = _dailyGoalRecords.get(today);
    return DailyGoal.fromJson(record);
  }

  DailyGoal getDailyGoalSettings() {
    final goal = settingsBox.get("dailyGoalSettings");
    return DailyGoal.fromJson(goal);
  }
}
