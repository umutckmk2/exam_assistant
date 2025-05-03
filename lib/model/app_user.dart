class AppUser {
  final String id;
  final String email;
  final List solvedQuestionIds;

  AppUser({
    required this.id,
    required this.email,
    required this.solvedQuestionIds,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      solvedQuestionIds: json['solvedQuestionIds'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'solvedQuestionIds': solvedQuestionIds};
  }
}
