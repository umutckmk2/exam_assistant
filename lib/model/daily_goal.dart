import 'package:flutter/material.dart';

class DailyGoal {
  final int dailyQuestionGoal;
  final int dailyTimeGoal;
  final TimeOfDay notifyTime;
  int? solvedQuestions;
  int? passTime;

  DailyGoal({
    required this.dailyQuestionGoal,
    required this.dailyTimeGoal,
    required this.notifyTime,
    this.solvedQuestions,
    this.passTime,
  });

  // Default constructor with preset values
  factory DailyGoal.defaultGoal() {
    return DailyGoal(
      dailyQuestionGoal: 25,
      dailyTimeGoal: 20,
      notifyTime: const TimeOfDay(hour: 20, minute: 0),
      solvedQuestions: 0,
      passTime: 0,
    );
  }

  factory DailyGoal.fromJson(Map json) {
    return DailyGoal(
      dailyQuestionGoal: json['dailyQuestionGoal'],
      dailyTimeGoal: json['dailyTimeGoal'],
      solvedQuestions: json['solvedQuestions'],
      passTime: json['passTime'],
      notifyTime: TimeOfDay(
        hour: json['notifyTime']['hour'],
        minute: json['notifyTime']['minute'],
      ),
    );
  }

  Map toJson() {
    return {
      'dailyQuestionGoal': dailyQuestionGoal,
      'dailyTimeGoal': dailyTimeGoal,
      'solvedQuestions': solvedQuestions,
      'passTime': passTime,
      'notifyTime': {'hour': notifyTime.hour, 'minute': notifyTime.minute},
    };
  }
}
