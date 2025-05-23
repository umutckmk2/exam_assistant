import 'daily_goal.dart';

class AppUser {
  final String id;
  final String email;
  final List solvedQuestions;
  final int updatedAt;
  final DailyGoal dailyGoalSettings;
  final bool isPremium;
  final String? subscriptionId;
  final int? subscriptionStart;

  AppUser({
    required this.id,
    required this.email,
    required this.solvedQuestions,
    required this.updatedAt,
    required this.dailyGoalSettings,
    this.isPremium = false,
    this.subscriptionId,
    this.subscriptionStart,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      solvedQuestions: json['solvedQuestions'] ?? [],
      updatedAt: json['updatedAt'],
      dailyGoalSettings: DailyGoal.fromJson(json['dailyGoalSettings']),
      isPremium: json['isPremium'] ?? false,
      subscriptionId: json['subscriptionId'],
      subscriptionStart: json['subscriptionStart'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'solvedQuestions': solvedQuestions,
      'updatedAt': updatedAt,
      'dailyGoalSettings': dailyGoalSettings.toJson(),
      'isPremium': isPremium,
      'subscriptionId': subscriptionId,
      'subscriptionStart': subscriptionStart,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    List? solvedQuestions,
    int? updatedAt,
    DailyGoal? dailyGoalSettings,
    bool? isPremium,
    String? subscriptionId,
    int? subscriptionStart,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      solvedQuestions: solvedQuestions ?? this.solvedQuestions,
      updatedAt: updatedAt ?? this.updatedAt,
      dailyGoalSettings: dailyGoalSettings ?? this.dailyGoalSettings,
      isPremium: isPremium ?? this.isPremium,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      subscriptionStart: subscriptionStart ?? this.subscriptionStart,
    );
  }
}
