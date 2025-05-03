import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../model/question_model.dart';

class QuestionService {
  static QuestionService? _instance;

  QuestionService._init();

  static QuestionService get instance {
    return _instance ?? QuestionService._init();
  }

  late Box<Map> _box;

  static const String _boxName = "questions";

  final _colRef = FirebaseFirestore.instance.collection(_boxName);

  Future<void> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<Map>(_boxName);
    } else {
      _box = await Hive.openBox<Map>(_boxName);
    }
  }

  Future<List<QuestionModel>> getQuestions({
    required String categoryId,
    required String lessonId,
    required Map topic,
    String? subTopicId,
  }) async {
    try {
      await _openBox();

      var paths = [];
      var questions = <QuestionModel>[];

      var path = "category/$categoryId/lessons/$lessonId/topics/${topic['id']}";
      if (subTopicId != null) {
        path += "/subtopics/$subTopicId";
        paths.add(path);
      } else {
        final subTopics = topic['subTopics'];
        for (var subTopic in subTopics) {
          paths.add(
            "category/$categoryId/lessons/$lessonId/topics/${topic['id']}/subtopics/${subTopic['value']}",
          );
        }
      }

      for (var path in paths) {
        try {
          final boxQuestions =
              _box.values.where((q) => q['topicPath'] == path).toList();
          if (boxQuestions.isNotEmpty) {
            questions.addAll(boxQuestions.map(QuestionModel.fromJson));
            continue;
          }
          final qs =
              await _colRef
                  .where('topicPath', isEqualTo: path)
                  .where('answer', isLessThan: 6)
                  .get();
          for (final question in qs.docs) {
            final data = {...question.data(), 'id': question.id};
            questions.add(QuestionModel.fromJson(data));
          }
        } catch (e) {
          print("error: $e");
          continue;
        }
      }

      await _box.putAll({
        for (var question in questions) question.id: question.toJson(),
      });

      return questions;
    } catch (e) {
      return [];
    }
  }

  Future<void> updateQuestion(QuestionModel question) async {
    await _openBox();
    await _colRef.doc(question.id).update({...question.toJson()});
    await _box.put(question.id, question.toJson());
  }
}
