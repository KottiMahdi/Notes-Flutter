import 'package:flutter/material.dart';

import '../../controllers/note_controller.dart';
import 'edit_note_view.dart';

/// New notes use the same rich-text editor as editing; with no note id the
/// editor creates the note when saved.
class AddNoteView extends StatelessWidget {
  final String categoryId;
  final NoteController? noteController;

  const AddNoteView({
    super.key,
    required this.categoryId,
    this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return EditNoteView(
      categoryId: categoryId,
      noteController: noteController,
    );
  }
}
