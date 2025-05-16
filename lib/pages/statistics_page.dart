import 'package:flutter/material.dart';

import '../model/solved_question_model.dart';
import '../service/auth_service.dart';
import '../service/questions_service.dart';
import '../service/user_service.dart';
import 'topic_analysis_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool _isLoading = true;
  final List<SolvedQuestionModel> _allQuestions = [];

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

      final solvedQuestionModel = SolvedQuestionModel.fromQuestionModel(
        question,
        solvedQuestion['answerIndex'],
        solvedQuestion['solvedAt'],
      );

      _allQuestions.add(solvedQuestionModel);
    }
    if (mounted) {
      _isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'İstatistikler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'İstatistikler yükleniyor...',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              )
              : _allQuestions.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 80,
                        color: Theme.of(context).primaryColor.withAlpha(125),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Henüz İstatistik Yok',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Çözülmüş soru bulunmamaktadır. Soru çözmeye başlayarak istatistiklerinizi görüntüleyebilirsiniz.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pop(); // Return to previous page
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Soru Çözmeye Başla'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : TopicAnalysisPage(solvedQuestions: _allQuestions),
    );
  }
}
