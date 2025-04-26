import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class LessonService {
  final String categoryId;

  static LessonService? _instance;

  LessonService._init(this.categoryId);

  factory LessonService(String categoryId) {
    if (_instance != null) {
      if (_instance!.categoryId != categoryId) {
        _instance = LessonService._init(categoryId);
      }
    } else {
      _instance = LessonService._init(categoryId);
    }
    return _instance!;
  }

  late Box<Map> _box;

  late String _boxName;

  Future<void> _openBox() async {
    _boxName = "$categoryId-lessons";
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<Map>(_boxName);
    } else {
      _box = await Hive.openBox<Map>(_boxName);
    }
  }

  Future<List<Map>> getLessons() async {
    await _openBox();

    if (_box.values.isNotEmpty) {
      return _box.values.toList();
    }

    final qs =
        await FirebaseFirestore.instance
            .collection('category')
            .doc(categoryId)
            .collection('lessons')
            .get();
    final lessons =
        qs.docs.map((doc) => {"id": doc.id, ...doc.data()}).toList();

    for (var lesson in lessons) {
      await _box.put(lesson['id'], lesson);
    }

    return lessons;
  }
}
