import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../model/index.dart';

class UserService {
  static final UserService instance = UserService._internal();

  factory UserService() => instance;

  UserService._internal();

  final _box = Hive.box('settings');
  Future<AppUser?> getUser(String id) async {
    try {
      final ds =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      final solvedQuestions =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(id)
              .collection('solvedQuestions')
              .get();
      if (ds.exists) {
        final user = AppUser.fromJson({
          ...ds.data()!,
          'id': id,
          'solvedQuestionIds':
              solvedQuestions.docs.isNotEmpty
                  ? solvedQuestions.docs.map((e) => e.id).toList()
                  : [],
        });

        await _box.put(id, user.toJson());
        return user;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  Future<void> saveUser(String id, Map user) async {
    await _box.put(id, user);
  }

  Future<AppUser> updateUser(AppUser user, Map updateData) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).update({
      ...updateData,
    });

    await _box.put(user.id, {...user.toJson(), ...updateData});

    return AppUser.fromJson({...user.toJson(), ...updateData});
  }

  Future<void> saveSolvedQuestion(String userId, Map question) async {
    final id = "${question['id']}";
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('solvedQuestions')
        .doc(id)
        .set({
          'solvedAt': DateTime.now(),
          'answerIndex': question['answer'],
          'correct': question['answer'] == question['answerIndex'],
        });
    final user = await _box.get(userId);
    await _box.put(userId, {
      ...user!,
      'solvedQuestionIds': [...user!['solvedQuestionIds'], id],
    });
  }

  Future<List> getSolvedQuestions(String userId) async {
    final user = await _box.get(userId);
    return user!['solvedQuestionIds'] ?? [];
  }
}
