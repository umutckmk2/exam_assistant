import 'package:flutter/material.dart';

import '../model/enums.dart';
import '../model/solved_question_model.dart';
import '../service/auth_service.dart';
import '../service/questions_service.dart';
import '../service/user_service.dart';
import '../widgets/intervals_widget.dart';
import 'topic_analysis_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _isLoading = true;
  final List<SolvedQuestionModel> _allQuestions = [];
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
      _allQuestions.add(
        SolvedQuestionModel.fromQuestionModel(
          question,
          solvedQuestion['answerIndex'],
          solvedQuestion['solvedAt'],
          solvedQuestion['correct'],
        ),
      );
    }
    print("all questions: ${_allQuestions.length}");
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

    if (_allQuestions.isEmpty) {
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
      body: TopicAnalysisPage(solvedQuestions: _allQuestions),
    );
  }
}
