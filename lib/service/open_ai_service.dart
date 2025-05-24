import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../model/question_model.dart';
import 'topic_service.dart';

class OpenAiService {
  static final OpenAiService _instance = OpenAiService._internal();

  factory OpenAiService() => _instance;

  OpenAiService._internal();

  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  late final String _apiKey;

  Future<void> initialize() async {
    _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key not found in .env file');
    }
  }

  Future<String> _sendRequest(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception(
          'Failed to get response: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error sending request to OpenAI: $e');
    }
  }

  Future<String> createCheatSheet(QuestionModel question) async {
    final topicInfo = await TopicService.instance.getSubTopic(
      question.subTopicNumber,
      question.topicNumber,
      question.category,
      question.lesson,
    );
    final prompt = '''
    You are an expert YKS (Yükseköğretime Geçiş Sınavı) tutor.

    For the given topic:
    Grade: ${question.category}
    Lesson: ${question.lesson}
    Topic: ${topicInfo.topic}
    Subtopic: ${topicInfo.subTopic}

    Provide a comprehensive study guide that includes:
    - Core concepts and definitions related to this topic
    - Key formulas and principles
    - Important historical context or background information
    - Common applications and real-world examples
    - Key relationships to other YKS topics
    - Common question patterns in YKS exams on this topic
    - Memory techniques and study tips for mastering this topic
    - Common mistakes students make and how to avoid them

    Format your response in clear, structured Turkish that would be helpful for a YKS candidate.
    ''';

    return await _sendRequest(prompt);
  }

  Future<String> generateSimilarQuestion(QuestionModel question) async {
    final topicInfo = await TopicService.instance.getSubTopic(
      question.subTopicNumber,
      question.topicNumber,
      question.category,
      question.lesson,
    );
    final prompt = '''
    You are an expert in KPSS (Public Personnel Selection Examination) question creation.

    Generate a similar KPSS question to the following, but with different wording, context, and values:
    
    Grade: ${question.category}
    Lesson: ${question.lesson}
    Topic: ${topicInfo.topic}
    Subtopic: ${topicInfo.subTopic}
    Question: ${question.question}
    Options: ${question.options.map((e) => e).join(', ')}
    Correct Answer Index: ${question.answer}
    
    Ensure the new question:
    - Maintains the same difficulty level
    - Tests the same core concept/knowledge
    - Is formatted appropriately for YKS examinations
    - Contains all necessary context for a complete understanding
    - Is clearly written with proper Turkish grammar and spelling
    - Includes 5 options (A-E) with only one correct answer
    
    Return your response in valid JSON format like this:
    {
      "question": "Your new question text here",
      "answer": 0, // index of correct answer (0-4, corresponding to A-E)
      "options": [
        "Option A text",
        "Option B text",
        "Option C text",
        "Option D text", 
        "Option E text"
      ]
    }
    
    IMPORTANT: Return ONLY the JSON, nothing else. Ensure it is valid JSON and properly escaped. The "answer" field must be a number (0-4) not a letter.
    ''';

    final response = await _sendRequest(prompt);

    try {
      // Try to parse the response, in case there's any text before or after the JSON
      final jsonRegex = RegExp(r'({[\s\S]*})');
      final match = jsonRegex.firstMatch(response);

      if (match != null) {
        return match.group(1)!;
      } else {
        return response; // Return the full response if no JSON match found
      }
    } catch (e) {
      throw Exception('Failed to parse JSON response: $e');
    }
  }

  // Method to process image-based questions
  Future<String> processImageQuestion(String imageUrl, String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant specialized in answering student questions.',
            },
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': imageUrl},
                },
              ],
            },
          ],
          'temperature': 0.7,
          'max_tokens': 800,
        }),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception(
          'Failed to process image: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error processing image with OpenAI: $e');
    }
  }
}
