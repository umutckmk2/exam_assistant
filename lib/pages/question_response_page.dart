import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';

import '../model/ai_response_model.dart';
import '../model/student_question_model.dart';
import '../service/student_question_service.dart';
import '../widgets/loading_indicator.dart';

class QuestionResponsePage extends StatefulWidget {
  final String questionId;

  const QuestionResponsePage({super.key, required this.questionId});

  @override
  State<QuestionResponsePage> createState() => _QuestionResponsePageState();
}

class _QuestionResponsePageState extends State<QuestionResponsePage> {
  bool _isLoading = true;
  bool _isCopying = false;
  String? _errorMessage;
  StudentQuestionModel? _question;
  AiResponseModel? _response;

  final StudentQuestionService _questionService =
      StudentQuestionService.instance;

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
  }

  Future<void> _loadQuestionData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await _questionService.getQuestionWithResponse(
        widget.questionId,
      );

      setState(() {
        _question = data['question'] as StudentQuestionModel;
        _response = data['response'] as AiResponseModel?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Veri yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_response == null) return;

    setState(() {
      _isCopying = true;
    });

    try {
      await Clipboard.setData(ClipboardData(text: _response!.responseText));
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cevap panoya kopyalandı'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kopyalama sırasında hata oluştu: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCopying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soru Cevabı'),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.go('/');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          if (_response != null)
            IconButton(
              icon: Icon(_isCopying ? Icons.check : Icons.copy),
              onPressed: _copyToClipboard,
              tooltip: 'Cevabı Kopyala',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Cevap yükleniyor...'),
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
                onPressed: _loadQuestionData,
                child: const Text('Yeniden Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_question == null) {
      return const Center(child: Text('Soru bulunamadı'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sorunuz:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 350),
              child: Image.network(
                _question!.imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    alignment: Alignment.center,
                    color: Colors.grey[300],
                    child: const Text(
                      'Resim yüklenemedi',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI Cevabı:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_response != null) ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: MarkdownBody(
                data: _response!.responseText,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16),
                  h1: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'AI cevabı henüz hazır değil. Lütfen bekleyiniz veya daha sonra tekrar kontrol ediniz.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
