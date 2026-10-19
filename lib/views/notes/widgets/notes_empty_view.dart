import 'package:flutter/material.dart';
import '../../../core/widgets/empty_view.dart';

class NotesEmptyView extends StatelessWidget {
  final VoidCallback? onAddNote;

  const NotesEmptyView({
    super.key,
    this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: Icons.sticky_note_2_outlined,
      title: 'No notes yet',
      message: 'Tap "Add Note" to capture your first idea in this workspace.',
      actionLabel: onAddNote == null ? null : 'Add note',
      onAction: onAddNote,
    );
  }
}
