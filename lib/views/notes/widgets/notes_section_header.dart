import 'package:flutter/material.dart';

class NotesSectionHeader extends StatelessWidget {
  final String title;
  final int noteCount;

  const NotesSectionHeader({
    super.key,
    required this.title,
    required this.noteCount,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark
        ? Colors.white60
        : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Text(
            '$noteCount ${noteCount == 1 ? 'note' : 'notes'}',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
