import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/controllers/category_controller.dart';
import 'package:notes_management_mobile_application/controllers/note_controller.dart';

void main() {
  group('CRUD + access control integration flow', () {
    test('owner can CRUD while intruder is blocked', () async {
      final firestore = FakeFirebaseFirestore();

      final ownerAuth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'owner-uid',
          email: 'owner@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );
      final intruderAuth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'intruder-uid',
          email: 'intruder@example.com',
          isEmailVerified: true,
        ),
        signedIn: true,
      );

      final ownerCategoryController =
          CategoryController(firestore: firestore, auth: ownerAuth);
      final ownerNoteController =
          NoteController(firestore: firestore, auth: ownerAuth);

      final intruderCategoryController =
          CategoryController(firestore: firestore, auth: intruderAuth);
      final intruderNoteController =
          NoteController(firestore: firestore, auth: intruderAuth);

      await ownerCategoryController.addCategory('Work');
      final categories = await ownerCategoryController.getCategories();
      expect(categories.length, 1);
      expect(categories.first.name, 'Work');

      final categoryId = categories.first.id;

      await ownerCategoryController.updateCategory(categoryId, 'Updated Work');
      final updatedCategories = await ownerCategoryController.getCategories();
      expect(updatedCategories.first.name, 'Updated Work');

      await ownerNoteController.addNote(categoryId, 'First secure note');
      final notes = await ownerNoteController.getNotes(categoryId);
      expect(notes.length, 1);
      expect(notes.first.note, 'First secure note');

      await ownerNoteController.editNote(
          categoryId, notes.first.id, 'Edited note');
      final editedNotes = await ownerNoteController.getNotes(categoryId);
      expect(editedNotes.first.note, 'Edited note');

      expect(
        () => intruderNoteController.editNote(
            categoryId, editedNotes.first.id, 'hacked'),
        throwsA(isA<FirebaseException>()),
      );
      expect(
        () =>
            intruderNoteController.deleteNote(categoryId, editedNotes.first.id),
        throwsA(isA<FirebaseException>()),
      );

      final intruderCategories =
          await intruderCategoryController.getCategories();
      expect(intruderCategories, isEmpty);

      expect(
        () => intruderNoteController.getNotes(categoryId),
        throwsA(isA<FirebaseException>()),
      );
      expect(
        () => intruderCategoryController.updateCategory(categoryId, 'hacked'),
        throwsA(isA<FirebaseException>()),
      );
      expect(
        () => intruderCategoryController.deleteCategory(categoryId),
        throwsA(isA<FirebaseException>()),
      );
      await ownerNoteController.deleteNote(categoryId, editedNotes.first.id);
      final afterDelete = await ownerNoteController.getNotes(categoryId);
      expect(afterDelete, isEmpty);
    });
  });
}
