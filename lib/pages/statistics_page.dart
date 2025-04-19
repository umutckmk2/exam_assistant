import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:osym/model/question_model.dart';
import 'package:osym/service/auth_service.dart';
import 'package:osym/service/question_service.dart';
import 'package:osym/utils/date_utils.dart';

import '../model/enums.dart';
import '../widgets/intervals_widget.dart';
import '../widgets/lesson_charts_widget.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _isLoading = true;
  final Map<String, List<AnswerCount>> _lessonData = {};
  late List<Question> _allQuestions;
  TimeInterval _selectedInterval = TimeInterval.week;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _lessonData.clear();

    final userId = AuthService().currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      _allQuestions = await QuestionService.instance.loadQuestions();
      int? startTimestamp;
      final DateTime now = DateTime.now();

      switch (_selectedInterval) {
        case TimeInterval.week:
          startTimestamp = toSeconds(now.subtract(const Duration(days: 7)));
          break;
        case TimeInterval.month:
          startTimestamp = toSeconds(now.subtract(const Duration(days: 30)));
          break;
        case TimeInterval.allTime:
          startTimestamp = null;
          break;
      }

      final solvedQuestionIds = await QuestionService.instance
          .getSolvedQuestionIds(userId, startTimestamp);
      DateTime? earliestSolvedDate;

      final Map<String, Map<int, AnswerStats>> lessonAnswersByDay = {};

      if (solvedQuestionIds.isNotEmpty) {
        for (final id in solvedQuestionIds) {
          final questionId = int.tryParse(id);
          if (questionId == null) continue;

          final question = _allQuestions.firstWhere(
            (q) => q.id == questionId,
            orElse:
                () => Question(
                  id: 0,
                  konu: 'Unknown',
                  soru: '',
                  cevap: 0,
                  aciklama: '',
                  secenekler: [],
                ),
          );

          if (question.id == 0) continue;
          final doc =
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .collection("solvedQuestions")
                  .doc(id)
                  .get();

          if (!doc.exists) continue;

          final data = doc.data();
          if (data == null) continue;

          final solvedAt = data['solvedAt'] as int;
          final answerIndex = data['answerIndex'] as int;
          final correctAnswer = data['answer'] as int;
          final isCorrect = answerIndex == correctAnswer;

          final solvedDate = fromSeconds(solvedAt);

          // Track earliest date for all time view
          if (earliestSolvedDate == null ||
              solvedDate.isBefore(earliestSolvedDate)) {
            earliestSolvedDate = solvedDate;
          }

          final dayTimestamp =
              DateTime(
                solvedDate.year,
                solvedDate.month,
                solvedDate.day,
              ).millisecondsSinceEpoch;

          // Initialize map for this lesson if not exists
          if (!lessonAnswersByDay.containsKey(question.konu)) {
            lessonAnswersByDay[question.konu] = {};
          }

          // Initialize or update stats for this day
          if (!lessonAnswersByDay[question.konu]!.containsKey(dayTimestamp)) {
            lessonAnswersByDay[question.konu]![dayTimestamp] = AnswerStats(
              0,
              0,
            );
          }

          final stats = lessonAnswersByDay[question.konu]![dayTimestamp]!;
          if (isCorrect) {
            lessonAnswersByDay[question.konu]![dayTimestamp] = AnswerStats(
              stats.correct + 1,
              stats.incorrect,
            );
          } else {
            lessonAnswersByDay[question.konu]![dayTimestamp] = AnswerStats(
              stats.correct,
              stats.incorrect + 1,
            );
          }
        }
      }

      for (final lessonEntry in lessonAnswersByDay.entries) {
        final lessonName = lessonEntry.key;
        final dayData = lessonEntry.value;

        final List<AnswerCount> chartData = [];

        if (_selectedInterval == TimeInterval.allTime &&
            earliestSolvedDate != null) {
          final DateTime startDate =
              DateTime.now()
                      .subtract(const Duration(days: 7))
                      .isBefore(earliestSolvedDate)
                  ? DateTime.now().subtract(const Duration(days: 7))
                  : earliestSolvedDate;

          final int totalDays = DateTime.now().difference(startDate).inDays + 1;

          for (int i = 0; i < totalDays; i++) {
            final day = startDate.add(Duration(days: i));
            final dayStart = DateTime(day.year, day.month, day.day);
            final dayTimestamp = dayStart.millisecondsSinceEpoch;

            final stats = dayData[dayTimestamp] ?? AnswerStats(0, 0);
            chartData.add(AnswerCount(day, stats.correct, stats.incorrect));
          }
        } else if (_selectedInterval == TimeInterval.month) {
          for (int i = 29; i >= 0; i--) {
            final day = DateTime.now().subtract(Duration(days: i));
            final dayStart = DateTime(day.year, day.month, day.day);
            final dayTimestamp = dayStart.millisecondsSinceEpoch;

            final stats = dayData[dayTimestamp] ?? AnswerStats(0, 0);
            chartData.add(AnswerCount(day, stats.correct, stats.incorrect));
          }
        } else {
          for (int i = 6; i >= 0; i--) {
            final day = DateTime.now().subtract(Duration(days: i));
            final dayStart = DateTime(day.year, day.month, day.day);
            final dayTimestamp = dayStart.millisecondsSinceEpoch;

            final stats = dayData[dayTimestamp] ?? AnswerStats(0, 0);
            chartData.add(AnswerCount(day, stats.correct, stats.incorrect));
          }
        }

        _lessonData[lessonName] = chartData;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_lessonData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('İstatistikler')),
        body: Column(
          children: [
            IntervalsWidget(
              selectedInterval: _selectedInterval,
              onIntervalChanged: (interval) {
                setState(() => _selectedInterval = interval);
                _loadData();
              },
            ),
            const Expanded(
              child: Center(
                child: Text('Seçilen aralıkta çözülmüş soru bulunmamaktadır'),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: Column(
        children: [
          IntervalsWidget(
            selectedInterval: _selectedInterval,
            onIntervalChanged: (interval) {
              setState(() => _selectedInterval = interval);
              _loadData();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Konulara Göre Çözülen Sorular',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  for (final entry in _lessonData.entries)
                    LessonChartsWidget(
                      lessonName: entry.key,
                      seletedInterval: _selectedInterval,
                      data: entry.value,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnswerStats {
  final int correct;
  final int incorrect;

  AnswerStats(this.correct, this.incorrect);
}

class AnswerCount {
  final DateTime date;
  final int correct;
  final int incorrect;

  AnswerCount(this.date, this.correct, this.incorrect);

  int get total => correct + incorrect;
}

double max(double a, double b) => a > b ? a : b;
