import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:osym/service/auth_service.dart';

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
  Map? _question;
  bool _isLoading = true;
  int? _selectedAnswerIndex;
  bool _showResult = false;
  final bool _isGeneratingAiQuestion = false;
  final bool _isGeneratingCheatSheet = false;
  String? _cheatSheetContent;
  List<Map>? _questionWithoutImage;
  List<Map>? _unsolvedQuestions;
  final ScrollController _scrollController = ScrollController();
  Map? _topic;

  Future<void> _loadQuestions() async {
    final topicService = TopicService(widget.lessonId, widget.categoryId);
    _topic = await topicService.getTopic(widget.topicId);

    final questionsService = QuestionsService.instance;
    final questions = await questionsService.getQuestions(
      categoryId: widget.categoryId,
      lessonId: widget.lessonId,
      topic: _topic!,
      subTopicId: widget.subTopicId,
    );

    _questionWithoutImage =
        questions
            .where((e) => !e['questionAsHtml'].toString().contains('<img'))
            .toList();
    _unsolvedQuestions =
        questions.where((e) => !e.containsKey('solvedAt')).toList();
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
    if (_questionWithoutImage == null || _questionWithoutImage!.isEmpty) return;
    final randomIndex = Random().nextInt(_questionWithoutImage!.length);
    final htmlQuestion = _questionWithoutImage![randomIndex];

    final paraphrasedQuestion = await OpenAiService()
        .extractAndParaphraseQuestionFromHtml(htmlQuestion['questionAsHtml']);

    _question = {...htmlQuestion, ...paraphrasedQuestion};

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

    _question!['answerIndex'] = index;

    await UserService.instance.saveSolvedQuestion(userId!, _question!);

    await QuestionsService.instance.saveSolvedQuestion(userId, _question!);
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
        appBar: AppBar(
          title: const Text('Bu konuda henüz soru bulunmamaktadır'),
        ),
        body: const Center(child: Text('Bu konuda henüz soru bulunmamaktadır')),
      );
    } else if (_unsolvedQuestions!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Bu konuda henüz soru bulunmamaktadır'),
        ),
        body: const Center(child: Text('Bu konuda henüz soru bulunmamaktadır')),
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
                                _question!['question'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (int i = 0; i < _question!['options'].length; i++)
                        AnswerOption(
                          answer: _question!['options'][i],
                          isSelected: _selectedAnswerIndex == i,
                          isCorrect: _showResult && i == _question!['answer'],
                          isWrong:
                              _showResult &&
                              _selectedAnswerIndex == i &&
                              i != _question!['answer'],
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
                                Text(
                                  _question!['explanation'] ?? 'Açıklama yok',
                                ),
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
