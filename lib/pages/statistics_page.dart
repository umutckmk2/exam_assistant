import 'package:flutter/material.dart';
import 'package:yksasistan/model/question_model.dart';

import '../model/enums.dart';
import '../service/auth_service.dart';
import '../service/questions_service.dart';
import '../service/user_service.dart';
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
  final List<QuestionModel> _allQuestions = [];
  TimeInterval _selectedInterval = TimeInterval.week;

  @override
  void initState() {
    super.initState();
    _getSolvedQuestions();
  }

  Future<void> _getSolvedQuestions() async {
    final user = await UserService.instance.getUserDetails(
      AuthService().currentUser!.uid,
    );

    final solvedQuestionIds = user?.solvedQuestions ?? [];
    for (final solvedQuestion in solvedQuestionIds) {
      final question = await QuestionService.instance.getQuestion(
        solvedQuestion['id'],
      );
      _allQuestions.add(question);
    }

    if (mounted) {
      _isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('İstatistikler')),
        body: Center(child: CircularProgressIndicator()),
      );
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
