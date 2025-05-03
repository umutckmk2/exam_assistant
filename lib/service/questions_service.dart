import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class QuestionsService {
  static QuestionsService? _instance;

  QuestionsService._init();

  static QuestionsService get instance {
    return _instance ?? QuestionsService._init();
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

  Future<List<Map>> getQuestions({
    required String categoryId,
    required String lessonId,
    required Map topic,
    String? subTopicId,
  }) async {
    try {
      await _openBox();

      var paths = [];
      var questions = <Map>[];

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
            questions.addAll(boxQuestions);
            continue;
          }
          final qs = await _colRef.where('topicPath', isEqualTo: path).get();
          questions.addAll(qs.docs.map((e) => e.data()).toList());
        } catch (e) {
          continue;
        }
      }

      await _box.putAll({
        for (var question in questions) question['id']: question,
      });

      return questions;
    } catch (e) {
      return [];
    }
  }

  Future<void> updateQuestion(String questionId, Map question) async {
    await _colRef.doc(_boxName).collection('questions').doc(questionId).update({
      ...question,
    });
  }

  Future<void> saveSolvedQuestion(String userId, Map question) async {
    await _openBox();
    await _box.put("${question['id']}", {
      ...question,
      'solvedAt': DateTime.now(),
      'userId': userId,
      'answerIndex': question['answerIndex'],
    });
  }
}
