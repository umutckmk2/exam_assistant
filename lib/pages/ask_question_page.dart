import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../service/student_question_service.dart';
import '../widgets/loading_indicator.dart';

class AskQuestionPage extends StatefulWidget {
  const AskQuestionPage({super.key});

  @override
  State<AskQuestionPage> createState() => _AskQuestionPageState();
}

class _AskQuestionPageState extends State<AskQuestionPage> {
  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  final StudentQuestionService _questionService =
      StudentQuestionService.instance;

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Resim seçilirken bir hata oluştu: $e';
      });
    }
  }

  Future<void> _submitQuestion() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'Lütfen bir soru resmi seçin';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Upload the question image and create a question record
      final question = await _questionService.createQuestion(_selectedImage!);

      // Process the image with AI
      await _questionService.processQuestionImage(question);

      if (!mounted) return;

      // Navigate to response page
      GoRouter.of(context).push('/question-response/${question.id}');
    } catch (e) {
      setState(() {
        _errorMessage = 'Soru işlenirken bir hata oluştu: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soru Sor'), elevation: 0),
      body:
          _isLoading
              ? const Center(
                child: LoadingIndicator(message: 'Sorunuz işleniyor...'),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'AI asistanınıza sormak istediğiniz sorunun görselini yükleyin',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24.0),
                    if (_selectedImage != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.file(
                          _selectedImage!,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Farklı bir resim seç'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                      ),
                    ] else ...[
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 60, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'Soru resmi ekleyin',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Soru Resmi Yükle'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24.0),
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                    if (_selectedImage != null)
                      ElevatedButton(
                        onPressed: _submitQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text(
                          'Soru Gönder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }
}
