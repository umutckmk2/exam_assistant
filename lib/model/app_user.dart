class AppUser {
  final String id;
  final String email;
  final List solvedQuestions;
  final int updatedAt;

  AppUser({
    required this.id,
    required this.email,
    required this.solvedQuestions,
    required this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      solvedQuestions: json['solvedQuestions'] ?? [],
      updatedAt: json['updatedAt'],
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
