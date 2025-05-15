import 'package:flutter/material.dart';

class DailyGoal {
  final int dailyQuestionGoal;
  final TimeOfDay notifyTime;
  int? solvedQuestions;

  DailyGoal({
    required this.dailyQuestionGoal,
    required this.notifyTime,
    this.solvedQuestions,
  });

  // Default constructor with preset values
  factory DailyGoal.defaultGoal() {
    return DailyGoal(
      dailyQuestionGoal: 25,
      notifyTime: const TimeOfDay(hour: 20, minute: 0),
      solvedQuestions: 0,
    );
  }

  factory DailyGoal.fromJson(Map json) {
    return DailyGoal(
      dailyQuestionGoal: json['dailyQuestionGoal'],
      solvedQuestions: json['solvedQuestions'],
      notifyTime: TimeOfDay(
        hour: json['notifyTime']['hour'],
        minute: json['notifyTime']['minute'],
      ),
    );
  }

  Map toJson() {
    return {
      'dailyQuestionGoal': dailyQuestionGoal,
      'solvedQuestions': solvedQuestions,
      'notifyTime': {'hour': notifyTime.hour, 'minute': notifyTime.minute},
    };
  }
}
