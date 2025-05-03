import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:osym/service/auth_service.dart';

import '../model/daily_goal.dart';
import '../model/question_model.dart';
import '../service/goals_service.dart';
import '../service/open_ai_service.dart';
import '../service/questions_service.dart';
import '../service/topic_service.dart';
import '../service/user_service.dart';
import '../widgets/answer_option.dart';

class QuestionPage extends StatefulWidget {
  final String topicId;
  final String lessonId;
  final String categoryId;
  final String? subTopicId;
  const QuestionPage({
    super.key,
    required this.topicId,
    required this.lessonId,
    required this.categoryId,
    this.subTopicId,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  QuestionModel? _question;
  bool _isLoading = true;
  int? _selectedAnswerIndex;
  bool _showResult = false;
  final bool _isGeneratingAiQuestion = false;
  final bool _isGeneratingCheatSheet = false;
  String? _cheatSheetContent;
  List<QuestionModel>? _questionWithoutImage;
  List<QuestionModel>? _unsolvedQuestions;
  final ScrollController _scrollController = ScrollController();
  Map? _topic;
  DailyGoal? _todayGoal;

  Future<void> _loadQuestions() async {
    final topicService = TopicService(widget.lessonId, widget.categoryId);
    _topic = await topicService.getTopic(widget.topicId);

    final questionsService = QuestionService.instance;
    final questions = await questionsService.getQuestions(
      categoryId: widget.categoryId,
      lessonId: widget.lessonId,
      topic: _topic!,
      subTopicId: widget.subTopicId,
    );

    _questionWithoutImage =
        questions.where((e) => !e.questionAsHtml.contains('<img')).toList();
    final userId = AuthService().currentUser?.uid;
    if (userId == null) return;
    print("questionWithoutImage: ${_questionWithoutImage!.length}");
    final solvedQuestions = await UserService.instance.getSolvedQuestions(
      userId,
    );
    _unsolvedQuestions =
        _questionWithoutImage!
            .where((e) => !solvedQuestions.any((s) => s['id'] == e.id))
            .toList();
    print("unsolved length: ${_unsolvedQuestions!.length}");

    print("unsolved Questions ids: ${_unsolvedQuestions!.map((e) => e.id)}");
    _loadRandomQuestion();
    _isLoading = false;
    if (mounted) setState(() {});
  }

  Future<void> _generateSimilarQuestion() async {
    // setState(() {
    //   _isGeneratingAiQuestion = true;
    // });

    // try {
    //   final question = await OpenAiService().generateSimilarQuestion(
    //     _question!,
    //   );

    //   final questionJson = jsonDecode(question);
    //   final questionModel = Question.fromJson({
    //     ...questionJson,
    //     "id": _question!.id + Random().nextInt(1000000),
    //     "bolum": "KPSS",
    //   });

    //   _question = questionModel;
    //   _selectedAnswerIndex = null;
    //   _showResult = false;
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(
    //       context,
    //     ).showSnackBar(SnackBar(content: Text('Soru oluşturulurken hata: $e')));
    //   }
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isGeneratingAiQuestion = false;
    //     });
    //   }
    // }
  }

  Future<void> _generateTopicCheatSheet() async {
    // if (_question == null) return;

    // setState(() {
    //   _isGeneratingCheatSheet = true;
    // });

    // try {
    //   final cheatSheet = await OpenAiService().getTopicCheatSheet(
    //     widget.topic,
    //     relatedQuestion: _question,
    //   );

    //   setState(() {
    //     _cheatSheetContent = cheatSheet;
    //   });

    //   _showCheatSheetDialog();
    // } catch (e) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('Konu özeti oluşturulurken hata: $e')),
    //     );
    //   }
    // } finally {
    //   if (mounted) {
    //     setState(() {
    //       _isGeneratingCheatSheet = false;
    //     });
    //   }
    // }
  }

  void _showCheatSheetDialog() {
    if (_cheatSheetContent == null) return;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    title: Text('${_topic!['topic']} - Konu Özeti'),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // Clipboard functionality would need to be added
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Konu özeti kopyalandı'),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        tooltip: 'Kopyala',
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        height: 600,
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Markdown(
                          data: _cheatSheetContent!,
                          styleSheet: MarkdownStyleSheet(
                            h1: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            p: TextStyle(fontSize: 16),
                            listBullet: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _loadRandomQuestion() async {
    if (_unsolvedQuestions == null || _unsolvedQuestions!.isEmpty) return;
    final randomIndex = Random().nextInt(_unsolvedQuestions!.length);
    final htmlQuestion = _unsolvedQuestions![randomIndex];

    final paraphrasedQuestion = await OpenAiService()
        .extractAndParaphraseQuestionFromHtml(htmlQuestion.questionAsHtml);

    _question = htmlQuestion.copyWith(
      paraphrasedQuestion: paraphrasedQuestion['paraphrasedQuestion'],
      options: paraphrasedQuestion['options'],
    );

    _showResult = false;
    _selectedAnswerIndex = null;

    await QuestionService.instance.updateQuestion(_question!);

    if (mounted) setState(() {});
  }

  Future<void> _checkAnswer(int index) async {
    _selectedAnswerIndex = index;
    _showResult = true;
    setState(() {});

    final userId = AuthService().currentUser?.uid;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });

    _question = _question!.copyWith(answerIndex: index);

    await UserService.instance.saveSolvedQuestion(userId!, _question!.toJson());

    _todayGoal ??= await GoalsService.instance.getTodayGoal(userId);

    _todayGoal!.solvedQuestions = (_todayGoal!.solvedQuestions ?? 0) + 1;

    _todayGoal = await GoalsService.instance.saveTodayRecord(_todayGoal!);
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_topic == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yükleniyor...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else if (_questionWithoutImage!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_topic!['topic'])),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.menu_book, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "Henüz Soru Yok 📝",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Bu konuda henüz soru bulunmamaktadır",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Konulara Dön"),
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
        ),
      );
    } else if (_unsolvedQuestions!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_topic!['topic'])),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  "Tebrikler! 🎉",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Bu konudaki tüm soruları başarıyla çözdünüz! 👏",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Konulara Dön"),
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
        ),
      );
    } else if (_question == null || _question!.paraphrasedQuestion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yükleniyor...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(_topic!['topic'])),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isGeneratingCheatSheet || _question == null
                              ? null
                              : _generateTopicCheatSheet,
                      icon:
                          _isGeneratingCheatSheet
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.amber,
                                ),
                              )
                              : const Icon(Icons.auto_awesome),
                      label: Text(
                        _isGeneratingCheatSheet
                            ? 'Hazırlanıyor...'
                            : 'Konu Özeti',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _question!.paraphrasedQuestion!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (int i = 0; i < _question!.options!.length; i++)
                AnswerOption(
                  answer: _question!.options![i],
                  isSelected: _selectedAnswerIndex == i,
                  isCorrect: _showResult && (i + 1) == _question!.answer,
                  isWrong:
                      _showResult &&
                      _selectedAnswerIndex == i &&
                      i + 1 != _question!.answer,
                  onTap: _showResult ? null : () => _checkAnswer(i),
                ),
              if (_showResult) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                _unsolvedQuestions!.removeWhere(
                                  (e) => e.id == _question!.id,
                                );
                                await _loadRandomQuestion();
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Yeni Soru'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed:
                          _isGeneratingAiQuestion
                              ? null
                              : _generateSimilarQuestion,
                      icon:
                          _isGeneratingAiQuestion
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.deepPurple,
                                ),
                              )
                              : const Icon(Icons.psychology),
                      label: Text(
                        _isGeneratingAiQuestion
                            ? 'Oluşturuluyor...'
                            : 'Benzer Soru',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
