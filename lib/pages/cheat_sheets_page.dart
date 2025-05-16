import 'package:flutter/material.dart';

import '../service/cheat_sheet_service.dart';
import '../service/topic_service.dart';
import '../utils/lesson_utils.dart';
import '../widgets/cheat_sheets/cheat_sheet_card_widget.dart';
import '../widgets/statistics/grade_filter_widget.dart';

class CheatSheetsPage extends StatefulWidget {
  const CheatSheetsPage({super.key});

  @override
  State<CheatSheetsPage> createState() => _CheatSheetsPageState();
}

class _CheatSheetsPageState extends State<CheatSheetsPage> {
  bool _isLoading = true;

  Map<String, Map<String, List<Map<String, dynamic>>>> _groupedCheatSheets = {};

  // Filter states
  Map<String, bool> _gradeFilters = {};
  Map<String, Map<String, bool>> _lessonFilters =
      {}; // Grade -> Lesson -> enabled

  @override
  void initState() {
    super.initState();
    _loadCheatSheets();
  }

  Future<void> _loadCheatSheets() async {
    setState(() => _isLoading = true);

    final cheatSheets = await CheatSheetService.instance.getCheatSheets();

    final categories = cheatSheets.map((sheet) => sheet['categoryId']).toSet();

    for (final category in categories) {
      final categoryCheatSheets =
          cheatSheets
              .where((sheet) => sheet['categoryId'] == category)
              .toList();
      final lessons =
          categoryCheatSheets.map((sheet) => sheet['lessonId']).toSet();
      _groupedCheatSheets[category] = {};
      for (final lesson in lessons) {
        final lessonCheatSheets =
            categoryCheatSheets
                .where((sheet) => sheet['lessonId'] == lesson)
                .toList();
        final topics =
            lessonCheatSheets.map((sheet) => sheet['topicId']).toSet();
        _groupedCheatSheets[category]![lesson] = [];
        for (final topicId in topics) {
          final topicCheatSheets =
              lessonCheatSheets
                  .where((sheet) => sheet['topicId'] == topicId)
                  .toList();
          final topic = await TopicService.instance.getTopic(
            topicId,
            category,
            lesson,
          );

          _groupedCheatSheets[category]![lesson]!.add({
            'topicTitle': topic['topic'],
            'cheatSheets': topicCheatSheets,
          });
        }
      }
    }

    // Sort categories to follow 9,10,11,12 order
    _groupedCheatSheets = Map.fromEntries(
      ['9', '10', '11', '12']
          .where((grade) => _groupedCheatSheets.containsKey(grade))
          .map((grade) => MapEntry(grade, _groupedCheatSheets[grade]!)),
    );

    // After setting _groupedTopics, initialize filters
    _initializeFilters();

    setState(() {
      _isLoading = false;
    });
  }

  void _initializeFilters() {
    // Initialize grade filters
    _gradeFilters = {for (var grade in _groupedCheatSheets.keys) grade: true};

    // Initialize lesson filters for each grade
    _lessonFilters = {
      for (var grade in _groupedCheatSheets.entries)
        grade.key: {for (var lesson in grade.value.keys) lesson: true},
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Konu Özetlerim')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradeFilterWidget(
            gradeFilters: _gradeFilters,
            lessonFilters: _lessonFilters,
            onFilterChange: (newGradeFilters, newLessonFilters) {
              setState(() {
                _gradeFilters = newGradeFilters;
                _lessonFilters = newLessonFilters;
              });
            },
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, gradeIndex) {
                    final grade = _groupedCheatSheets.keys.elementAt(
                      gradeIndex,
                    );
                    if (!(_gradeFilters[grade] ?? true)) {
                      return const SizedBox.shrink();
                    }
                    final lessonGroups = _groupedCheatSheets[grade]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            "$grade. Sınıf",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        for (final entry in lessonGroups.entries)
                          if (_lessonFilters[grade]?[entry.key] ?? true)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    LessonUtils.getLessonName(entry.key),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                for (final topic in entry.value)
                                  CheatSheetCardWidget(cheatSheet: topic),
                              ],
                            ),
                      ],
                    );
                  }, childCount: _groupedCheatSheets.length),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
