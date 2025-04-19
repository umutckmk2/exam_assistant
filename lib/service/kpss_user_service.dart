import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

import '../model/index.dart';

class KpssUserService {
  static final KpssUserService instance = KpssUserService._internal();

  factory KpssUserService() => instance;

  KpssUserService._internal();

  final _box = Hive.box('settings');

  Future<KpssUser?> getUser(String id) async {
    final ds =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    final solvedQuestions =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .collection('solvedQuestions')
            .get();
    if (ds.exists && solvedQuestions.docs.isNotEmpty) {
      final user = KpssUser.fromJson({
        ...ds.data()!,
        'id': id,
        'solvedQuestionIds':
            solvedQuestions.docs.map((e) => int.parse(e.id)).toList(),
      });

      await _box.put(id, user.toJson());
      return user;
    }
    return null;
  }

  Future<KpssUser> updateUser(KpssUser user, Map updateData) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).update({
      ...updateData,
    });

    await _box.put(user.id, {...user.toJson(), ...updateData});

    return KpssUser.fromJson({...user.toJson(), ...updateData});
  }
}
