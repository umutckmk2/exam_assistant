import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../model/index.dart';

class UserService {
  static final UserService instance = UserService._internal();

  factory UserService() => instance;

  UserService._internal();

  final _box = Hive.box('settings');

  Future<void> updatePremiumStatus({
    required String userId,
    required bool isPremium,
    String? subscriptionId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final updateData = {
      'isPremium': isPremium,
      'subscriptionId': subscriptionId,
      'subscriptionStart': isPremium ? now : null,
      'updatedAt': now,
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update(updateData);

    final user = await _box.get(userId);
    if (user != null) {
      await _box.put(userId, {...user, ...updateData});
    }
  }

  Future<bool> isPremiumUser(String userId) async {
    try {
      final user = await getUserDetails(userId);
      return user?.isPremium ?? false;
    } catch (e) {
      debugPrint('Error checking premium status: $e');
      return false;
    }
  }

  Future<AppUser?> getUserDetails(String id) async {
    try {
      final user = await _box.get(id);
      final updatedAt = user?['updatedAt'] ?? 0;
      var solvedQuestions = [];
      var ds =
          await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (!ds.exists) {
        final createdAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await FirebaseFirestore.instance.collection('users').doc(id).set({
          'id': id,
          'createdAt': createdAt,
          'updatedAt': createdAt,
          'lastLogin': createdAt,
          'isPremium': false,
          'subscriptionId': null,
          'subscriptionStart': null,
        });

        ds = await FirebaseFirestore.instance.collection('users').doc(id).get();
      }
      final fbUpdatedAt = ds.data()?['updatedAt'] ?? 0;
      if (fbUpdatedAt > updatedAt) {
        final solvedQuestionQs =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(id)
                .collection('solvedQuestions')
                .get();

        if (solvedQuestionQs.docs.isEmpty) {
          solvedQuestions = [];
        } else {
          for (final question in solvedQuestionQs.docs) {
            final questionData = {
              "answerIndex": question.data()['answerIndex'],
              "correct":
                  question.data()['correctAnswer'] ==
                  question.data()['answerIndex'],
              "id": question.id,
              "solvedAt": question.data()['solvedAt'],
            };
            solvedQuestions.add(questionData);
          }
        }
      } else {
        solvedQuestions = user?['solvedQuestions'] ?? [];
      }
      final dailyGoalSettings = ds.data()?['dailyGoalSettings'] ?? {};
      final appUser = AppUser.fromJson({
        ...ds.data()!,
        'id': id,
        'solvedQuestions': solvedQuestions,
        'dailyGoalSettings': dailyGoalSettings,
      });

      await _box.put(id, appUser.toJson());
      return appUser;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  Future<void> deleteUser(String id) async {
    await _box.delete(id);
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

  Future<void> saveSolvedQuestion(
    String userId,
    Map question,
    int answerIndex,
  ) async {
    final id = "${question['id']}";
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);
      final solvedQuestionRef = userRef.collection('solvedQuestions').doc(id);

      transaction.set(solvedQuestionRef, {
        'solvedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'answerIndex': answerIndex,
        'correctAnswer': question['answer'],
      });

      transaction.update(userRef, {
        'updatedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
    });

    final user = await _box.get(userId);
    await _box.put(userId, {
      ...user!,
      'solvedQuestions': [...user!['solvedQuestions'], question],
    });
  }

  Future<List> getSolvedQuestions(String userId) async {
    final user = await _box.get(userId);
    return user!['solvedQuestions'] as List? ?? [];
  }
}
