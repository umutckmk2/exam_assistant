// Student question model to store image-based questions
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentQuestionModel {
  final String id;
  final String userId;
  final String imageUrl;
  final int createdAt; // Seconds since epoch
  final String? responseId; // Reference to the corresponding AI response
  final String? title; // Question title

  StudentQuestionModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    required this.title,
    this.responseId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'responseId': responseId,
      'title': title,
    };
  }

  factory StudentQuestionModel.fromMap(Map<String, dynamic> map) {
    return StudentQuestionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt:
          map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).seconds
              : map['createdAt'] ?? 0,
      responseId: map['responseId'],
      title: map['title'],
    );
  }

  StudentQuestionModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    int? createdAt,
    String? responseId,
    String? title,
  }) {
    return StudentQuestionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      responseId: responseId ?? this.responseId,
      title: title ?? this.title,
    );
  }

  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
}
