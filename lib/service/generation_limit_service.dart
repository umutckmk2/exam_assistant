import 'package:cloud_firestore/cloud_firestore.dart';

import '../main.dart';

class GenerationLimitService {
  static final GenerationLimitService instance =
      GenerationLimitService._internal();
  static const int nonPremiumDailyLimit = 10;
  static const int premiumDailyLimit = 50;

  GenerationLimitService._internal();

  Future<Map<String, dynamic>> getUserGenerationData(String userId) async {
    final doc =
        await FirebaseFirestore.instance
            .collection('user_generations')
            .doc(userId)
            .get();

    if (!doc.exists) {
      return {
        'count': 0,
        'lastResetDate': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };
    }

    return doc.data() as Map<String, dynamic>;
  }

  Future<bool> canGenerateMore(String userId) async {
    final isPremium = userNotifier.value?.isPremium ?? false;
    final generationData = await getUserGenerationData(userId);

    final lastResetDate = DateTime.fromMillisecondsSinceEpoch(
      (generationData['lastResetDate'] as int) * 1000,
    );
    final now = DateTime.now();

    print('lastResetDate: $lastResetDate');
    print('now: $now');
    print('isSameDay: ${_isSameDay(lastResetDate, now)}');
    print('isPremium: $isPremium');
    print('generationData: $generationData');
    print('count: ${generationData['count']}');
    print('limit: ${isPremium ? premiumDailyLimit : nonPremiumDailyLimit}');
    print('currentCount: ${generationData['count']}');

    // Reset counter if it's a new day
    if (!_isSameDay(lastResetDate, now)) {
      await _resetGenerationCount(userId);
      return true;
    }

    final currentCount = generationData['count'] as int;
    final limit = isPremium ? premiumDailyLimit : nonPremiumDailyLimit;

    return currentCount < limit;
  }

  Future<void> incrementGenerationCount(String userId) async {
    final generationData = await getUserGenerationData(userId);
    final lastResetDate = DateTime.fromMillisecondsSinceEpoch(
      (generationData['lastResetDate'] as int) * 1000,
    );
    final now = DateTime.now();

    if (!_isSameDay(lastResetDate, now)) {
      await _resetGenerationCount(userId);
      return;
    }

    await FirebaseFirestore.instance
        .collection('user_generations')
        .doc(userId)
        .set({
          'count': (generationData['count'] as int) + 1,
          'lastResetDate': generationData['lastResetDate'],
        });
  }

  Future<int> getRemainingGenerations(String userId) async {
    final isPremium = userNotifier.value?.isPremium ?? false;
    final generationData = await getUserGenerationData(userId);

    final lastResetDate = DateTime.fromMillisecondsSinceEpoch(
      (generationData['lastResetDate'] as int) * 1000,
    );
    final now = DateTime.now();

    if (!_isSameDay(lastResetDate, now)) {
      await _resetGenerationCount(userId);
      return isPremium ? premiumDailyLimit : nonPremiumDailyLimit;
    }

    final currentCount = generationData['count'] as int;
    final limit = isPremium ? premiumDailyLimit : nonPremiumDailyLimit;

    return limit - currentCount;
  }

  Future<void> _resetGenerationCount(String userId) async {
    await FirebaseFirestore.instance
        .collection('user_generations')
        .doc(userId)
        .set({
          'count': 0,
          'lastResetDate': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
