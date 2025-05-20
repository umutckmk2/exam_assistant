import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/ai_response_model.dart';
import '../model/student_question_model.dart';
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
  Future<AiResponseModel> processQuestionImage(
    StudentQuestionModel question,
  ) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Create prompt for OpenAI with the image context
      final prompt = '''
      This is an image of a student's question. First, identify what subject and topic this question is about.
      Then, provide a detailed and helpful explanation for the answer. 
      If there's text in the image, interpret it carefully and make sure to address the exact question being asked.
      If the image contains math equations or diagrams, explain the concepts involved step by step.
      
      Format your response in clear, structured Turkish that would be helpful for a YKS candidate.
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
