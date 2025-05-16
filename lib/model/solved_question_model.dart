import 'question_model.dart';

class SolvedQuestionModel extends QuestionModel {
  final int solvedAt;
  final int answerIndex;
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
  });

  factory SolvedQuestionModel.fromQuestionModel(
    QuestionModel question,
    int answerIndex,
    int solvedAt,
  ) {
    return SolvedQuestionModel(
      id: question.id,
      questionAsHtml: question.questionAsHtml,
      questionText: question.questionText,
      sourceFile: question.sourceFile,
      topicPath: question.topicPath,
      url: question.url,
      withImage: question.withImage,
      answer: question.answer,
      question: question.question,
      options: question.options,
      isAiGenerated: question.isAiGenerated,
      solvedAt: solvedAt,
      answerIndex: answerIndex,
    );
  }

  bool get isCorrect => answerIndex == answer;
}
