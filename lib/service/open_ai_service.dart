import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

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

  // Future<String> describeMore(Question question) async {
  //   final prompt = '''
  //   You are an expert KPSS (Public Personnel Selection Examination) tutor.

  //   Provide a detailed explanation of the following KPSS topic and question:

  //   Topic: ${question.ders}
  //   Question: ${question.soru}
  //   Options: ${question.secenekler.map((e) => e).join(', ')}
  //   Correct Answer Index: ${question.cevap}
  //   Explanation provided: ${question.aciklama}

  //   Include:
  //   - Core concepts and definitions related to this KPSS topic
  //   - Detailed explanation of why the correct answer is right
  //   - Why each wrong option is incorrect
  //   - Important historical context or background information
  //   - Key relationships to other KPSS topics
  //   - Common question patterns in KPSS exams on this topic
  //   - Memory techniques for remembering critical information

  //   Format your response in clear, structured Turkish that would be helpful for a KPSS candidate.
  //   ''';

  //   return await _sendRequest(prompt);
  // }

  Future<Map<String, dynamic>> extractAndParaphraseQuestionFromHtml(
    String htmlContent,
  ) async {
    try {
      // Extract the question and options using OpenAI instead of CSS selectors
      final extractionResult = await _extractQuestionFromHtmlUsingAI(
        htmlContent,
      );

      if (extractionResult == null) {
        throw Exception('Failed to extract question from HTML');
      }

      final originalQuestion = extractionResult['question'] as String;
      final options = extractionResult['options'] as List<String>;

      return {'paraphrasedQuestion': originalQuestion, 'options': options};
    } catch (e) {
      throw Exception('Error extracting and paraphrasing question: $e');
    }
  }

  Future<Map<String, dynamic>?> _extractQuestionFromHtmlUsingAI(
    String htmlContent,
  ) async {
    try {
      final prompt = '''
      You are an expert in extracting exam questions from HTML content.
      
      I will provide you with HTML content containing an exam question and its multiple-choice options.
      Your task is to extract the question text and the options as separate items.
      
      HTML content:
      ```
      $htmlContent
      ```
      
      Extract and return ONLY in the following JSON format:
      {
        "question": "The full question text here",
        "options": ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"]
      }
      
      Guidelines:
      - Extract the complete question text, including any context or paragraphs preceding the actual question
      - Extract all options exactly as they appear
      - Return valid JSON only, nothing else
      - If you cannot find a question or options, return an empty question or options array
      - Do not include option letters (A, B, C, etc.) in the option text unless they are part of the actual content
      ''';

      final response = await _sendRequest(prompt);

      try {
        // Try to parse the JSON response
        final jsonRegex = RegExp(r'({[\s\S]*})');
        final match = jsonRegex.firstMatch(response);

        if (match != null) {
          final jsonStr = match.group(1)!;
          final Map<String, dynamic> data = jsonDecode(jsonStr);

          if (data.containsKey('question') && data.containsKey('options')) {
            return {
              'question': data['question'] as String,
              'options': (data['options'] as List).cast<String>(),
            };
          }
        }

        return null;
      } catch (e) {
        debugPrint('Failed to parse extraction response: $e');
        return null;
      }
    } catch (e) {
      debugPrint('Error in _extractQuestionFromHtmlUsingAI: $e');
      return null;
    }
  }

  Future<String> _paraphraseQuestion(
    String question,
    List<String> options,
  ) async {
    final optionsText = options.map((opt) => '- $opt').join('\n');

    final prompt = '''
    You are an expert in KPSS (Public Personnel Selection Examination) question creation.
    
    Paraphrase the following exam question while ensuring the meaning and difficulty remain exactly the same.
    DO NOT modify the options or change any key terms that would make the original correct answer invalid.
    
    Original Question: $question
    
    Options:
    $optionsText
    
    Important rules:
    - Maintain exactly the same meaning and test the same knowledge
    - Keep the same difficulty level
    - Don't change the nature of what's being asked
    - Preserve all key terms that are referenced in the options
    - Ensure all options remain valid with your new question wording
    - Use proper Turkish grammar and spelling
    
    Return ONLY the paraphrased question text, nothing else.
    ''';

    return await _sendRequest(prompt);
  }
}
