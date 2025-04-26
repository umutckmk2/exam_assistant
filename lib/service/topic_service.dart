import 'package:cloud_firestore/cloud_firestore.dart';
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
    _boxName = "$categoryId-$lessonId-topics";
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<Map>(_boxName);
    } else {
      _box = await Hive.openBox<Map>(_boxName);
    }
  }

  Future<List<Map>> getTopics() async {
    await _openBox();

    if (_box.values.isNotEmpty) {
      return _box.values.toList();
    }

    final qs =
        await FirebaseFirestore.instance
            .collection('category')
            .doc(categoryId)
            .collection('lessons')
            .doc(lessonId)
            .collection('topics')
            .get();
    final topics = qs.docs.map((doc) => {"id": doc.id, ...doc.data()}).toList();

    for (var topic in topics) {
      await _box.put(topic['id'], topic);
    }

    await FirebaseFirestore.instance
        .collection('category')
        .doc(categoryId)
        .collection('lessons')
        .doc(lessonId)
        .update({"numberOfTopics": topics.length});
    return topics;
  }
}
