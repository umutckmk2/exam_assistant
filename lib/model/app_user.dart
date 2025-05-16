import 'daily_goal.dart';

class AppUser {
  final String id;
  final String email;
  final List solvedQuestions;
  final int updatedAt;
  final DailyGoal dailyGoalSettings;

  AppUser({
    required this.id,
    required this.email,
    required this.solvedQuestions,
    required this.updatedAt,
    required this.dailyGoalSettings,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      solvedQuestions: json['solvedQuestions'] ?? [],
      updatedAt: json['updatedAt'],
      dailyGoalSettings: DailyGoal.fromJson(json['dailyGoalSettings']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'solvedQuestions': solvedQuestions,
      'updatedAt': updatedAt,
    };
  }
}
