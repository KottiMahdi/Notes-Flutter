import 'package:flutter/material.dart';

class NotesEmptyView extends StatelessWidget {
  final bool isDark;

  const NotesEmptyView({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? Colors.white60 : const Color(0xFF6B7280);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sticky_note_2_outlined, size: 56, color: muted),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap "Add Note" to capture your first idea in this workspace.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
