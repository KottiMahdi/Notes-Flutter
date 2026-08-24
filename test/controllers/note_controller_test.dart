import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/note_controller.dart';

void main() {
  group('NoteController', () {
    test('getNotes returns notes for the current user only', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();
      const categoryId = 'category-1';

      await firestore.collection('categories').doc(categoryId).set({
        'name': 'Work',
        'userId': 'owner-user',
      });
      await firestore
          .collection('categories')
          .doc(categoryId)
          .collection('note')
          .add({
        'note': 'My private note',
        'userId': 'owner-user',
      });
      await firestore
          .collection('categories')
          .doc(categoryId)
          .collection('note')
          .add({
        'note': 'Other user note',
        'userId': 'other-user',
      });

      final controller = NoteController(firestore: firestore, auth: auth);
      final notes = await controller.getNotes(categoryId);

      expect(notes.length, 1);
      expect(notes.first.note, 'My private note');
      expect(notes.first.userId, 'owner-user');
    });

    test('addNote creates a note linked to the selected category and user',
        () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();
      const categoryId = 'category-1';
      await firestore.collection('categories').doc(categoryId).set({
        'name': 'Work',
        'userId': 'owner-user',
      });

      final controller = NoteController(firestore: firestore, auth: auth);
      await controller.addNote(categoryId, 'New secure note');

      final notes = await firestore
          .collection('categories')
          .doc(categoryId)
          .collection('note')
          .get();
      expect(notes.docs.length, 1);
      expect(notes.docs.first.data()['note'], 'New secure note');
      expect(notes.docs.first.data()['userId'], 'owner-user');
    });

    test('editNote updates an owned note', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();
      const categoryId = 'category-1';
      final created = await firestore
          .collection('categories')
          .doc(categoryId)
          .collection('note')
          .add({
        'note': 'Before',
        'userId': 'owner-user',
      });
      await firestore.collection('categories').doc(categoryId).set({
        'name': 'Work',
        'userId': 'owner-user',
      });

      final controller = NoteController(firestore: firestore, auth: auth);
      await controller.editNote(categoryId, created.id, 'After');

      final updated = await firestore
          .collection('categories')
          .doc(categoryId)
          .collection('note')
          .doc(created.id)
          .get();
      expect(updated.data()!['note'], 'After');
      expect(updated.data()!['userId'], 'owner-user');
    });

    test('deleteNote removes only an owned note', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();
      const categoryId = 'category-1';
      await firestore.collection('categories').doc(categoryId).set({
        'name': 'Work',
        'userId': 'owner-user',
      });
      final noteId = (await firestore
              .collection('categories')
              .doc(categoryId)
              .collection('note')
              .add({
        'note': 'Please delete',
        'userId': 'owner-user',
      }))
          .id;

      final controller = NoteController(firestore: firestore, auth: auth);
      await controller.deleteNote(categoryId, noteId);

      final remaining = await firestore
          .collection('categories')
          .doc(categoryId)
          .collection('note')
          .get();
      expect(remaining.docs, isEmpty);
    });

    test('getNotes and editNote reject unauthorized category or note access',
        () async {
      final ownerAuth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final intruderAuth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'intruder-user',
          email: 'intruder@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();
      const categoryId = 'category-1';
      final noteId = (await firestore
              .collection('categories')
              .doc(categoryId)
              .collection('note')
              .add({
        'note': 'Private note',
        'userId': 'owner-user',
      }))
          .id;
      await firestore.collection('categories').doc(categoryId).set({
        'name': 'Private work',
        'userId': 'owner-user',
      });

      final controller =
          NoteController(firestore: firestore, auth: intruderAuth);

      expect(
        () => controller.getNotes(categoryId),
        throwsA(isA<FirebaseException>()),
      );
      expect(
        () => controller.editNote(categoryId, noteId, 'Hacked'),
        throwsA(isA<FirebaseException>()),
      );
      expect(ownerAuth.currentUser, isNotNull);
    });

    test('addNote rejects empty text', () async {
      final auth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-user',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();
      const categoryId = 'category-1';
      await firestore.collection('categories').doc(categoryId).set({
        'name': 'Work',
        'userId': 'owner-user',
      });

      final controller = NoteController(firestore: firestore, auth: auth);
      expect(
        () => controller.addNote(categoryId, '   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
