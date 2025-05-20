// Student question model to store image-based questions
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentQuestionModel {
  final String id;
  final String userId;
  final String imageUrl;
  final DateTime createdAt;
  final String? responseId; // Reference to the corresponding AI response

  StudentQuestionModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    this.responseId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'responseId': responseId,
    };
  }

  factory StudentQuestionModel.fromMap(Map<String, dynamic> map) {
    return StudentQuestionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      responseId: map['responseId'],
    );
  }

  StudentQuestionModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    DateTime? createdAt,
    String? responseId,
  }) {
    return StudentQuestionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      responseId: responseId ?? this.responseId,
    );
  }
}
