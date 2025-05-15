class QuestionModel {
  final String id;
  final String questionAsHtml;
  final String questionText;
  final String sourceFile;
  final String question;
  final String topicPath;
  final String url;
  final bool withImage;
  final int answer;
  final List options;
  final bool isAiGenerated;

  QuestionModel({
    required this.id,
    required this.questionAsHtml,
    required this.questionText,
    required this.sourceFile,
    required this.topicPath,
    required this.url,
    required this.withImage,
    required this.answer,
    required this.question,
    required this.options,
    required this.isAiGenerated,
  });

  factory QuestionModel.fromJson(Map json) {
    return QuestionModel(
      id: json['id'],
      questionAsHtml: json['questionAsHtml'],
      questionText: json['questionText'],
      topicPath: json['topicPath'],
      url: json['url'],
      withImage: json['withImage'],
      answer: json['answer'],
      question: json['question'],
      sourceFile: json['sourceFile'],
      options: json['options'],
      isAiGenerated: json['isAiGenerated'] ?? false,
    );
  }

  Map toJson() {
    return {
      'id': id,
      'questionAsHtml': questionAsHtml,
      'questionText': questionText,
      'topicPath': topicPath,
      'url': url,
      'withImage': withImage,
      'answer': answer,
      'question': question,
      'sourceFile': sourceFile,
      'options': options,
      'isAiGenerated': isAiGenerated,
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
    String? question,
    String? sourceFile,
    List? options,
    int? answer,
    bool? isAiGenerated,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      questionAsHtml: questionAsHtml ?? this.questionAsHtml,
      questionText: questionText ?? this.questionText,
      topicPath: topicPath ?? this.topicPath,
      url: url ?? this.url,
      withImage: withImage ?? this.withImage,
      question: question ?? this.question,
      sourceFile: sourceFile ?? this.sourceFile,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
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
