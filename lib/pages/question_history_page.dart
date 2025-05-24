import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../model/student_question_model.dart';
import '../service/student_question_service.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/premium_banner_widget.dart';

class QuestionHistoryPage extends StatefulWidget {
  const QuestionHistoryPage({super.key});

  @override
  State<QuestionHistoryPage> createState() => _QuestionHistoryPageState();
}

class _QuestionHistoryPageState extends State<QuestionHistoryPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<StudentQuestionModel> _questions = [];

  final StudentQuestionService _questionService =
      StudentQuestionService.instance;

  @override
  void initState() {
    super.initState();
    _loadQuestionHistory();
  }

  Future<void> _loadQuestionHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final questions = await _questionService.getUserQuestions();

      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Soru geçmişi yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DhAppBar(title: const Text('Soru Geçmişim'), elevation: 0),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/ask-question');
        },
        icon: const Icon(
          Icons.add_photo_alternate,
          size: 20,
          color: Colors.white,
        ),
        label: const Text(
          'Yeni Soru',
          style: TextStyle(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Sorular yükleniyor...'),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadQuestionHistory,
                child: const Text('Yeniden Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.question_answer_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                'Henüz hiç soru sormadınız',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Yeni bir soru sormak için sağ alttaki butonu kullanabilirsiniz',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return RefreshIndicator(
      onRefresh: _loadQuestionHistory,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        itemCount: _questions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final question = _questions[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.network(
                  question.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            title: Text(
              question.title ?? 'Soru ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              dateFormat.format(question.createdAtDateTime),
              style: const TextStyle(fontSize: 12),
            ),
            trailing:
                question.responseId != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.hourglass_top, color: Colors.orange),
            onTap: () {
              GoRouter.of(context).push('/question-response/${question.id}');
            },
          );
        },
      ),
    );
  }
}
