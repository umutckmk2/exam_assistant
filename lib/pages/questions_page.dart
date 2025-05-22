import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../model/daily_goal.dart';
import '../model/question_model.dart';
import '../service/cheat_sheet_service.dart';
import '../service/index.dart';
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
  bool _isGeneratingAiQuestion = false;
  bool _isGeneratingCheatSheet = false;
  List<QuestionModel>? _questions;
  List<QuestionModel>? _unsolvedQuestions;
  final ScrollController _scrollController = ScrollController();
  Map? _topic;
  DailyGoal? _todayGoal;
  String? _cheatSheetContent;

  Future<void> _loadQuestions() async {
    _topic = await TopicService.instance.getTopic(
      widget.topicId,
      widget.categoryId,
      widget.lessonId,
    );

    final questionsService = QuestionService.instance;
    _questions = await questionsService.getQuestions(
      categoryId: widget.categoryId,
      lessonId: widget.lessonId,
      topic: _topic!,
      subTopicId: widget.subTopicId,
    );

    final userId = AuthService().currentUser?.uid;
    if (userId == null) return;
    final solvedQuestions = await UserService.instance.getSolvedQuestions(
      userId,
    );
    _unsolvedQuestions =
        _questions!
            .where((e) => !solvedQuestions.any((s) => s['id'] == e.id))
            .toList();
    _loadRandomQuestion();
    _isLoading = false;
    if (mounted) setState(() {});
  }

  Future<void> _generateSimilarQuestion() async {
    setState(() {
      _isGeneratingAiQuestion = true;
    });

    try {
      final question = await OpenAiService().generateSimilarQuestion(
        _question!,
      );

      final questionJson = jsonDecode(question);
      final questionModel = QuestionModel(
        answer: questionJson['answer'] + 1,
        options: questionJson['options'],
        question: questionJson['question'],
        questionAsHtml: "",
        questionText: "",
        id: _question!.id + Random().nextInt(1000000).toString(),
        sourceFile: "",
        topicPath: _question!.topicPath,
        url: "",
        withImage: false,
        isAiGenerated: true,
      );

      await QuestionService.instance.saveQuestion(questionModel);

      _question = questionModel;
      _selectedAnswerIndex = null;
      _showResult = false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Soru oluşturulurken hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAiQuestion = false;
        });
      }
    }
  }

  Future<void> _generateTopicCheatSheet() async {
    if (_question == null) return;

    setState(() {
      _isGeneratingCheatSheet = true;
    });

    setState(() {
      _cheatSheetContent = null;
    });

    try {
      final description = await OpenAiService().createCheatSheet(_question!);
      _cheatSheetContent = description;
      _isGeneratingCheatSheet = false;
      final cheatSheet = {
        'content': description,
        'topicId': widget.topicId,
        'lessonId': widget.lessonId,
        'categoryId': widget.categoryId,
        'subTopicId': widget.subTopicId,
      };
      await CheatSheetService.instance.saveCheatSheet(cheatSheet);
      if (mounted) setState(() {});

      _showCheatSheetDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konu özeti oluşturulurken hata: $e')),
        );
      }
    }
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
    _question = _unsolvedQuestions![randomIndex];

    _showResult = false;
    _selectedAnswerIndex = null;

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

    await UserService.instance.saveSolvedQuestion(
      userId!,
      _question!.toJson(),
      index + 1,
    );

    _todayGoal ??= await GoalsService.instance.getTodayGoal();

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
    } else if (_questions!.isEmpty) {
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
    } else if (_question == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Yükleniyor...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_topic!['topic']),
          // bottom: PreferredSize(
          //   preferredSize: const Size.fromHeight(60),
          //   child: Container(
          //     padding: const EdgeInsets.only(bottom: 8),
          //     child: const BannerAdWidget(),
          //   ),
          // ),
        ),
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
                        _question!.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (int i = 0; i < _question!.options.length; i++)
                AnswerOption(
                  answer: _question!.options[i],
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
                    const SizedBox(width: 16),
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
                              : const Text(
                                'Yeni Soru',
                                style: TextStyle(color: Colors.black),
                              ),
                    ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
