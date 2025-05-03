class QuestionModel {
  final String id;
  final String questionAsHtml;
  final String questionText;
  final String topicPath;
  final String url;
  final bool withImage;
  final int answerIndex;
  final String? paraphrasedQuestion;
  final List<String>? options;

  QuestionModel({
    required this.id,
    required this.questionAsHtml,
    required this.questionText,
    required this.topicPath,
    required this.url,
    required this.withImage,
    required this.answerIndex,
    this.paraphrasedQuestion,
    this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? 0,
      questionAsHtml: json['questionAsHtml'] ?? '',
      questionText: json['questionText'] ?? '',
      topicPath: json['topicPath'] ?? '',
      url: json['url'] ?? '',
      withImage: json['withImage'] ?? false,
      answerIndex: json['answerIndex'] ?? 0,
      paraphrasedQuestion: json['paraphrasedQuestion'] ?? '',
      options: json['options'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionAsHtml': questionAsHtml,
      'questionText': questionText,
      'topicPath': topicPath,
      'url': url,
      'withImage': withImage,
      'answerIndex': answerIndex,
      'paraphrasedQuestion': paraphrasedQuestion,
      'options': options,
    };
  }

  QuestionModel copyWith({
    String? id,
    String? questionAsHtml,
    String? questionText,
    String? topicPath,
    String? url,
    bool? withImage,
    int? answerIndex,
    String? paraphrasedQuestion,
    List<String>? options,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionAsHtml: questionAsHtml ?? this.questionAsHtml,
      questionText: questionText ?? this.questionText,
      topicPath: topicPath ?? this.topicPath,
      url: url ?? this.url,
      withImage: withImage ?? this.withImage,
      answerIndex: answerIndex ?? this.answerIndex,
      paraphrasedQuestion: paraphrasedQuestion ?? this.paraphrasedQuestion,
      options: options ?? this.options,
    );
  }

  String get lesson {
    final parts = topicPath.split('/');
    final lessonIndex = parts.indexOf('lessons');
    if (lessonIndex >= 0 && lessonIndex + 1 < parts.length) {
      return parts[lessonIndex + 1];
    }
    return '';
  }

  String get category {
    final parts = topicPath.split('/');
    final categoryIndex = parts.indexOf('category');
    if (categoryIndex >= 0 && categoryIndex + 1 < parts.length) {
      return parts[categoryIndex + 1];
    }
    return '';
  }

  String get topicNumber {
    final parts = topicPath.split('/');
    final topicsIndex = parts.indexOf('topics');
    if (topicsIndex >= 0 && topicsIndex + 1 < parts.length) {
      return parts[topicsIndex + 1];
    }
    return '';
  }

  String get subTopicNumber {
    final parts = topicPath.split('/');
    final subTopicsIndex = parts.indexOf('subtopics');
    if (subTopicsIndex >= 0 && subTopicsIndex + 1 < parts.length) {
      return parts[subTopicsIndex + 1];
    }
    return '';
  }
}
