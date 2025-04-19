class KpssUser {
  final String id;
  final String email;
  final List<int> solvedQuestionIds;

  KpssUser({
    required this.id,
    required this.email,
    required this.solvedQuestionIds,
  });

  factory KpssUser.fromJson(Map<String, dynamic> json) {
    return KpssUser(
      id: json['id'],
      email: json['email'],
      solvedQuestionIds: json['solvedQuestionIds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'solvedQuestionIds': solvedQuestionIds};
  }
}
