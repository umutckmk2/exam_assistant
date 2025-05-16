import 'package:hive/hive.dart';

class CheatSheetService {
  static final CheatSheetService _instance = CheatSheetService._internal();

  CheatSheetService._internal();

  late Box<Map> _cheatSheetRecords;

  static CheatSheetService get instance => _instance;

  Future<void> _openBox() async {
    if (Hive.isBoxOpen("cheatSheetRecords")) {
      _cheatSheetRecords = Hive.box<Map>("cheatSheetRecords");
    } else {
      _cheatSheetRecords = await Hive.openBox<Map>("cheatSheetRecords");
    }
  }

  Future<void> saveCheatSheet(Map<String, dynamic> cheatSheet) async {
    await _openBox();
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _cheatSheetRecords.put(id, cheatSheet);
  }

  Future<List<Map>> getCheatSheets() async {
    await _openBox();
    return _cheatSheetRecords.values.toList();
  }

  Future<void> deleteCheatSheet(String id) async {
    await _openBox();
    await _cheatSheetRecords.delete(id);
  }
}
