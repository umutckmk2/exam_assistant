import 'package:flutter/material.dart';

import '../model/solved_question_model.dart';
import '../service/topic_service.dart';
import '../utils/lesson_utils.dart';
import '../widgets/statistics/grade_filter_widget.dart';
import '../widgets/statistics/map_legend_widget.dart';
import '../widgets/statistics/topic_card_widget.dart';

class TopicAnalysisPage extends StatefulWidget {
  const TopicAnalysisPage({super.key, required this.solvedQuestions});

  final List<SolvedQuestionModel> solvedQuestions;

  @override
  State<TopicAnalysisPage> createState() => _TopicAnalysisPageState();
}

class _TopicAnalysisPageState extends State<TopicAnalysisPage> {
  Map<String, Map<String, List<Map<String, dynamic>>>> _groupedTopics = {};
  bool _isLoading = true;

  // Filter states
  Map<String, bool> _gradeFilters = {};
  Map<String, Map<String, bool>> _lessonFilters =
      {}; // Grade -> Lesson -> enabled

  @override
  void initState() {
    super.initState();
    _getQuestionInfo();
  }

  void _initializeFilters() {
    // Initialize grade filters
    _gradeFilters = {for (var grade in _groupedTopics.keys) grade: true};

    // Initialize lesson filters for each grade
    _lessonFilters = {
      for (var grade in _groupedTopics.entries)
        grade.key: {for (var lesson in grade.value.keys) lesson: true},
    };
  }

  Future<void> _getQuestionInfo() async {
    _isLoading = true;
    setState(() {});

    final categories =
        widget.solvedQuestions.map((question) => question.category).toSet();
    for (final category in categories) {
      final categoryQuestions =
          widget.solvedQuestions
              .where((question) => question.category == category)
              .toList();
      final lessons =
          categoryQuestions.map((question) => question.lesson).toSet();
      _groupedTopics[category] = {};
      for (final lesson in lessons) {
        final lessonQuestions =
            categoryQuestions
                .where((question) => question.lesson == lesson)
                .toList();
        final topics =
            lessonQuestions.map((question) => question.topicNumber).toSet();
        _groupedTopics[category]![LessonUtils.getLessonName(lesson)] = [];
        for (final topicNumber in topics) {
          final questions =
              lessonQuestions
                  .where((question) => question.topicNumber == topicNumber)
                  .toList();

          final correct =
              questions.where((question) => question.isCorrect).length;

          final total = questions.length;
          final percentage = (correct / total * 100).toInt();

          final topic = await TopicService.instance.getTopic(
            topicNumber,
            category,
            lesson,
          );

          final lessonName = LessonUtils.getLessonName(lesson);
          final topicData = {
            'name': topic['topic'],
            'lesson': lessonName,
            'grade': category,
            'correct': correct,
            'total': total,
            'percentage': percentage,
            'status':
                percentage >= 80
                    ? 'strong'
                    : percentage >= 50
                    ? 'developing'
                    : 'critical',
          };

          _groupedTopics[category]![lessonName]!.add(topicData);
        }
      }
    }

    // Sort categories to follow 9,10,11,12 order
    _groupedTopics = Map.fromEntries(
      ['9', '10', '11', '12']
          .where((grade) => _groupedTopics.containsKey(grade))
          .map((grade) => MapEntry(grade, _groupedTopics[grade]!)),
    );

    // After setting _groupedTopics, initialize filters
    _initializeFilters();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.map, size: 28, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Text(
                      'Güç Haritası',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 12),
                // OutlinedButton.icon(
                //   onPressed: _showAnalyzeDialog,
                //   icon: const Icon(Icons.analytics),
                //   label: const Text('AI ile Analiz Et'),
                //   style: OutlinedButton.styleFrom(
                //     foregroundColor: Colors.blue,
                //     side: const BorderSide(color: Colors.blue),
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 16,
                //       vertical: 8,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

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
                SliverToBoxAdapter(child: MapLegendWidget()),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, gradeIndex) {
                    final grade = _groupedTopics.keys.elementAt(gradeIndex);
                    if (!(_gradeFilters[grade] ?? true)) {
                      return const SizedBox.shrink();
                    }
                    final lessonGroups = _groupedTopics[grade]!;
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
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                for (final topic in entry.value)
                                  TopicCardWidget(topic: topic),
                              ],
                            ),
                      ],
                    );
                  }, childCount: _groupedTopics.length),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
