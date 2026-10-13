import 'note_model.dart';

class CategorizedNoteModel {
  final NoteModel note;
  final String categoryId;
  final String categoryName;

  const CategorizedNoteModel({
    required this.note,
    required this.categoryId,
    required this.categoryName,
  });
}
