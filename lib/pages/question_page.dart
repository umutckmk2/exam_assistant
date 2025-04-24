import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';

import '../model/question_model.dart';
import '../service/auth_service.dart';
import '../service/open_ai_service.dart';
import '../service/question_service.dart';
import '../widgets/answer_option.dart';

class QuestionPage extends StatefulWidget {
  final String topic;

  const QuestionPage({super.key, required this.topic});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  Question? _question;
  bool _isLoading = true;
  int? _selectedAnswerIndex;
  bool _showResult = false;
  bool _isGeneratingAiQuestion = false;
  bool _isGeneratingCheatSheet = false;
  String? _cheatSheetContent;
  List<Question> _questions = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadRandomQuestion();
  }

  Future<void> _loadRandomQuestion() async {
    _questions = await QuestionService.instance.loadQuestions();
    _isLoading = true;
    _selectedAnswerIndex = null;
    _showResult = false;
    setState(() {});

    final userId = AuthService().currentUser?.uid;

    final solvedQuestionIds = await QuestionService.instance
        .getSolvedQuestionIds(userId!);

    final topicQuestions =
        _questions
            .where(
              (q) =>
                  q.ders.toLowerCase() == widget.topic.toLowerCase() &&
                  !solvedQuestionIds.contains("${q.id}"),
            )
            .toList();

    if (topicQuestions.isEmpty) {
      _isLoading = false;
      setState(() {});
      return;
    }
    final random = Random();
    final randomIndex = random.nextInt(topicQuestions.length);
    _question = topicQuestions[randomIndex];
    _isLoading = false;
    setState(() {});
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
      final questionModel = Question.fromJson({
        ...questionJson,
        "id": _question!.id + Random().nextInt(1000000),
        "bolum": "KPSS",
      });

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

    try {
      final cheatSheet = await OpenAiService().getTopicCheatSheet(
        widget.topic,
        relatedQuestion: _question,
      );

      setState(() {
        _cheatSheetContent = cheatSheet;
      });

      _showCheatSheetDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konu özeti oluşturulurken hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingCheatSheet = false;
        });
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
                    title: Text('${widget.topic} - Konu Özeti'),
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

  void _checkAnswer(int index) {
    _selectedAnswerIndex = index;
    _showResult = true;
    setState(() {});

    final userId = AuthService().currentUser?.uid;
    QuestionService.instance.addSolvedQuestion(
      userId: userId!,
      question: _question!,
      answerIndex: index,
    );

    // Scroll to bottom after a short delay to allow the widgets to render
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.topic),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRandomQuestion,
              tooltip: 'Yeni Soru',
            ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _question == null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Bu konuda henüz soru bulunmamaktadır',
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Geri Dön'),
                        ),
                      ],
                    ),
                  ),
                )
                : SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                _question!.soru,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (int i = 0; i < _question!.secenekler.length; i++)
                        AnswerOption(
                          answer: _question!.secenekler[i],
                          isSelected: _selectedAnswerIndex == i,
                          isCorrect: _showResult && i == _question!.cevap,
                          isWrong:
                              _showResult &&
                              _selectedAnswerIndex == i &&
                              i != _question!.cevap,
                          onTap: _showResult ? null : () => _checkAnswer(i),
                        ),
                      if (_showResult) ...[
                        const SizedBox(height: 20),
                        Card(
                          color: Colors.amber.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Açıklama:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(_question!.aciklama),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _loadRandomQuestion,
                              child: const Text('Yeni Soru'),
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
