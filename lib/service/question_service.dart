import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:osym/model/question_model.dart';

import '../utils/date_utils.dart';

class QuestionService {
  // Private constructor
  QuestionService._();

  // Singleton instance
  static final QuestionService _instance = QuestionService._();

  // Public accessor
  static QuestionService get instance => _instance;

  Future<List<Question>> loadQuestions() async {
    try {
      final response = await rootBundle.loadString('assets/kpss.json');
      final List data = jsonDecode(response);
      return data.map((item) => Question.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load questions: $e');
    }
  }

  Future<void> addSolvedQuestion({
    required String userId,
    required Question question,
    required int answerIndex,
  }) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userRef = FirebaseFirestore.instance
          .collection("users")
          .doc(userId);
      final solvedQuestionRef = userRef
          .collection("solvedQuestions")
          .doc("${question.id}");

      transaction.set(solvedQuestionRef, {
        "solvedAt": toSeconds(DateTime.now()),
        "answerIndex": answerIndex,
        "answer": question.cevap,
      });

      transaction.update(userRef, {"updatedAt": toSeconds(DateTime.now())});
    });
  }

  Future<List<String>> getSolvedQuestionIds(String userId, [int? date]) async {
    final qs =
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("solvedQuestions")
            .where("solvedAt", isGreaterThan: date)
            .get();

    if (qs.docs.isEmpty) return [];

    return qs.docs.map((e) => e.id).toList();
  }
}
