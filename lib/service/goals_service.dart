import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../model/daily_goal.dart';
import 'auth_service.dart';

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
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc('daily')
        .set({...goal.toJson()});
  }

  Future<void> resetDailyGoal() async {
    final userId = AuthService().currentUser?.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc('daily')
        .delete();
  }

  Future<void> saveTodayRecord(DailyGoal goal) async {
    await _openBox();
    final userId = AuthService().currentUser?.uid;

    final record = _dailyGoalRecords.get(todayMidNightAsSeconds);
    if (record == null) {
      await _dailyGoalRecords.put(todayMidNightAsSeconds, goal.toJson());
      await FirebaseDatabase.instance
          .ref('users/$userId/goals/daily/records/$todayMidNightAsSeconds')
          .set({...goal.toJson()});
    }
  }

  Future<void> saveMissingRecords() async {
    await _openBox();
    try {
      final userId = AuthService().currentUser?.uid;

      final dailyGoalSettings = getDailyGoalSettings();
      final lastRecordSnapshot =
          await FirebaseDatabase.instance
              .ref('users/$userId/goals/daily/records')
              .orderByKey()
              .limitToLast(1)
              .get();

      if (lastRecordSnapshot.value == null) {
        await saveTodayRecord(dailyGoalSettings);
        return;
      }

      final lastRecordTime = int.parse(
        (lastRecordSnapshot.value as Map).keys.first,
      );

      final lastRecordDate = DateTime.fromMillisecondsSinceEpoch(
        lastRecordTime * 1000,
      );
      final today = DateTime.fromMillisecondsSinceEpoch(
        todayMidNightAsSeconds * 1000,
      );
      final daysBetween = today.difference(lastRecordDate).inDays;

      if (daysBetween <= 1) return;

      for (var i = 1; i < daysBetween; i++) {
        final missingDate = lastRecordDate.add(Duration(days: i));
        final missingTimestamp = missingDate.millisecondsSinceEpoch ~/ 1000;

        await _dailyGoalRecords.put(
          missingTimestamp,
          dailyGoalSettings.toJson(),
        );

        await FirebaseDatabase.instance
            .ref('users/$userId/goals/daily/records/$missingTimestamp')
            .set(dailyGoalSettings.toJson());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> saveDailyGoalSettings(String userId, DailyGoal goal) async {
    await settingsBox.put("dailyGoalSettings", goal.toJson());
    await FirebaseDatabase.instance.ref('users/$userId/goals/daily').set({
      ...goal.toJson(),
    });
  }

  Future<Map<String, DailyGoal>> getThisWeekGoalRecords(String userId) async {
    final dailyGoalSettings = getDailyGoalSettings();
    final thisWeekDatesAsSeconds = [];
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
      if (timestamp <= todayMidNightAsSeconds) {
        final record = _dailyGoalRecords.get(
          timestamp,
          defaultValue: dailyGoalSettings.toJson(),
        );
        thisWeekRecords[timestamp.toString()] = DailyGoal.fromJson(record!);
      } else {
        thisWeekRecords[timestamp.toString()] = dailyGoalSettings;
      }
    }

    return thisWeekRecords;
  }

  DailyGoal getDailyGoalSettings() {
    final goal = settingsBox.get(
      "dailyGoalSettings",
      defaultValue: DailyGoal.defaultGoal().toJson(),
    );
    return DailyGoal.fromJson(goal!);
  }
}
