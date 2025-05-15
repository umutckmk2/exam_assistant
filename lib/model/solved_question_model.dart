import 'question_model.dart';

class SolvedQuestionModel extends QuestionModel {
  final int solvedAt;
  final int answerIndex;
  final bool correct;
  SolvedQuestionModel({
    required super.id,
    required super.questionAsHtml,
    required super.questionText,
    required super.sourceFile,
    required super.topicPath,
    required super.url,
    required super.withImage,
    required super.answer,
    required super.question,
    required super.options,
    required super.isAiGenerated,
    required this.solvedAt,
    required this.answerIndex,
    required this.correct,
  });
}
