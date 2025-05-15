import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

class TopicService {
  final String lessonId;
  final String categoryId;

  static TopicService? _instance;

  TopicService._init(this.lessonId, this.categoryId);

  factory TopicService(String lessonId, String categoryId) {
    if (_instance != null) {
      if (_instance!.lessonId != lessonId ||
          _instance!.categoryId != categoryId) {
        _instance = TopicService._init(lessonId, categoryId);
      }
    } else {
      _instance = TopicService._init(lessonId, categoryId);
    }
    return _instance!;
  }

  late Box<Map> _box;

  late String _boxName;

  Future<void> _openBox() async {
    _boxName = "$categoryId-$lessonId-mainTopics";
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<Map>(_boxName);
    } else {
      _box = await Hive.openBox<Map>(_boxName);
    }
  }

  Future<List<Map>> getTopics() async {
    await _openBox();

    final qs =
        await FirebaseFirestore.instance
            .collection('category')
            .doc(categoryId)
            .collection('lessons')
            .doc(lessonId)
            .collection('mainTopics')
            .get();
    final topics = <Map>[];

    for (final doc in qs.docs) {
      final topic = {
        "id": doc.id,
        ...doc.data(),
        "lessonId": lessonId,
        "categoryId": categoryId,
      };
      topics.add(topic);
    }

    // Sort by doc id converted to int
    topics.sort((a, b) => int.parse(a['id']).compareTo(int.parse(b['id'])));

    for (var topic in topics) {
      await _box.put(topic['id'], topic);
    }

    return topics;
  }

  Future<Map> getTopic(String topicId) async {
    await _openBox();

    if (_box.containsKey(topicId)) {
      return _box.get(topicId)!;
    }

    final ds =
        await FirebaseFirestore.instance
            .collection('category')
            .doc(categoryId)
            .collection('lessons')
            .doc(lessonId)
            .collection('mainTopics')
            .doc(topicId)
            .get();
    final topic = ds.data();

    await _box.put(topicId, {
      "id": topicId,
      ...topic!,
      "lessonId": lessonId,
      "categoryId": categoryId,
    });

    return topic;
  }

  Future<({String topic, String subTopic})> getSubTopic(
    String subTopicId,
    String topicId,
  ) async {
    final topic = await getTopic(topicId);
    final subTopic = (topic['subTopics'] as List? ?? []).firstWhereOrNull(
      (subTopic) => subTopic['value'] == subTopicId,
    );
    return (
      topic: topic['topic'] as String,
      subTopic: subTopic['text'] as String,
    );
  }
}
