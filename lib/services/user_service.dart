import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/error/guarded_call.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveUserDetails(String uid, UserModel user) {
    return guardedCall(
      isWrite: true,
      () => _firestore.collection('Users').doc(uid).set(
        {
          ...user.toMap(),
          'uid': uid,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ),
    );
  }

  Future<void> deleteUserData(String uid) {
    return guardedCall(
      isWrite: true,
      timeout: const Duration(seconds: 60),
      () async {
        final categories = await _firestore
            .collection('categories')
            .where('userId', isEqualTo: uid)
            .get();
        final batch = _firestore.batch();

        for (final category in categories.docs) {
          final notes = await category.reference.collection('note').get();
          for (final note in notes.docs) {
            batch.delete(note.reference);
          }
          batch.delete(category.reference);
        }

        batch.delete(_firestore.collection('Users').doc(uid));
        await batch.commit();
      },
    );
  }
}
