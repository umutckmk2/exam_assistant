import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../model/ai_response_model.dart';
import '../model/student_question_model.dart';
import '../widgets/limit_exceeded_dialog.dart';
import 'generation_limit_service.dart';
import 'open_ai_service.dart';

class StudentQuestionService {
  static final StudentQuestionService _instance =
      StudentQuestionService._internal();
  static StudentQuestionService get instance => _instance;
  factory StudentQuestionService() => _instance;
  StudentQuestionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final OpenAiService _openAiService = OpenAiService();

  // Collection references
  CollectionReference get _questionsCollection =>
      _firestore.collection('student_questions');
  CollectionReference get _responsesCollection =>
      _firestore.collection('ai_responses');

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get current time as seconds since epoch
  int get _currentTimeSeconds => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  // Upload image to Firebase Storage
  Future<String> uploadQuestionImage(File imageFile) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    final fileName = '${_userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef = _storage.ref().child(
      'question_images/$_userId/$fileName',
    );

    try {
      final uploadTask = await storageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Create a new student question
  Future<StudentQuestionModel> createQuestion(
    File imageFile, {
    String? title,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Upload image and get URL
      final imageUrl = await uploadQuestionImage(imageFile);

      // Create question document
      final questionId = _questionsCollection.doc().id;
      final question = StudentQuestionModel(
        id: questionId,
        userId: _userId!,
        imageUrl: imageUrl,
        createdAt: _currentTimeSeconds,
        title: title ?? 'Soru ${_formatDate(_currentTimeSeconds)}',
      );

      // Save to Firestore
      await _questionsCollection.doc(questionId).set(question.toMap());

      return question;
    } catch (e) {
      throw Exception('Failed to create question: $e');
    }
  }

  // Helper function to format date for default title
  String _formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}.${date.month}.${date.year}';
  }

  // Process the image using OpenAI's API
  Future<AiResponseModel?> processQuestionImage(
    StudentQuestionModel question,
    BuildContext context,
  ) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    // Check generation limits before calling the service
    final generationLimitService = GenerationLimitService.instance;
    final canGenerate = await generationLimitService.canGenerateMore(_userId!);

    if (!canGenerate) {
      final remainingGenerations = await generationLimitService
          .getRemainingGenerations(_userId!);
      final isPremium = userNotifier.value?.isPremium ?? false;
      final limit =
          isPremium
              ? GenerationLimitService.premiumDailyLimit
              : GenerationLimitService.nonPremiumDailyLimit;

      if (context.mounted) {
        await showDialog(
          context: context,
          builder:
              (context) => LimitExceededDialog(
                isPremium: isPremium,
                remainingGenerations: remainingGenerations,
                dailyLimit: limit,
              ),
        );
      }

      return null;
    }

    try {
      // Create prompt for OpenAI with the image context
      final prompt = '''
      First, analyze if this image contains a multiple choice exam question with options (A, B, C, D, E).

      If it IS an exam question:
      1. Identify the subject and topic
      2. Explain the correct answer step by step
      3. Indicate which option is correct and why
      4. Format the response in clear Turkish suitable for a YKS candidate

      If it is NOT an exam question:
      Respond with: "Bu görsel bir sınav sorusu değil. Sadece YKS sınavına yönelik test sorularını yanıtlayabilirim." 

      Remember: Only provide academic analysis for actual exam questions with options.
      ''';

      // Get AI response from OpenAI service
      final responseText = await _openAiService.processImageQuestion(
        question.imageUrl,
        prompt,
      );

      // Create response document
      final responseId = _responsesCollection.doc().id;
      final response = AiResponseModel(
        id: responseId,
        questionId: question.id,
        userId: _userId!,
        responseText: responseText,
        createdAt: _currentTimeSeconds,
      );

      // Save to Firestore
      await _responsesCollection.doc(responseId).set(response.toMap());

      // Update question with response ID
      await _questionsCollection.doc(question.id).update({
        'responseId': responseId,
      });

      return response;
    } catch (e) {
      throw Exception('Failed to process question image: $e');
    }
  }

  // Get questions for a specific user
  Future<List<StudentQuestionModel>> getUserQuestions() async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final snapshot =
          await _questionsCollection
              .where('userId', isEqualTo: _userId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map(
            (doc) => StudentQuestionModel.fromMap(
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get user questions: $e');
    }
  }

  // Get a specific response
  Future<AiResponseModel?> getResponse(String responseId) async {
    try {
      final doc = await _responsesCollection.doc(responseId).get();

      if (doc.exists) {
        return AiResponseModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get response: $e');
    }
  }

  // Get a question with its response
  Future<Map<String, dynamic>> getQuestionWithResponse(
    String questionId,
  ) async {
    try {
      // Get question
      final questionDoc = await _questionsCollection.doc(questionId).get();
      final question = StudentQuestionModel.fromMap(
        questionDoc.data() as Map<String, dynamic>,
      );

      // Get response if it exists
      AiResponseModel? response;
      if (question.responseId != null) {
        response = await getResponse(question.responseId!);
      }

      return {'question': question, 'response': response};
    } catch (e) {
      throw Exception('Failed to get question with response: $e');
    }
  }
}
