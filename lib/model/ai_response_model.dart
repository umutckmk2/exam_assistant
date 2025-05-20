// AI response model to store responses to student questions
import 'package:cloud_firestore/cloud_firestore.dart';

class AiResponseModel {
  final String id;
  final String questionId;
  final String userId;
  final String responseText;
  final int createdAt; // Seconds since epoch

  AiResponseModel({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.responseText,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'userId': userId,
      'responseText': responseText,
      'createdAt': createdAt,
    };
  }

  factory AiResponseModel.fromMap(Map<String, dynamic> map) {
    return AiResponseModel(
      id: map['id'] ?? '',
      questionId: map['questionId'] ?? '',
      userId: map['userId'] ?? '',
      responseText: map['responseText'] ?? '',
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).seconds
              : map['createdAt'] ?? 0,
    );
  }

  AiResponseModel copyWith({
    String? id,
    String? questionId,
    String? userId,
    String? responseText,
    int? createdAt,
  }) {
    return AiResponseModel(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      userId: userId ?? this.userId,
      responseText: responseText ?? this.responseText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
}
