import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'note_toolbar_button.dart';

class NoteFormattingToolbar extends StatelessWidget {
  final bool isDark;
  final bool Function(Attribute attribute) isFormatActive;
  final ValueChanged<Attribute> onToggleFormat;
  final bool hasLink;
  final VoidCallback onAddLink;

  const NoteFormattingToolbar({
    super.key,
    required this.isDark,
    required this.isFormatActive,
    required this.onToggleFormat,
    required this.hasLink,
    required this.onAddLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFEFEAE1),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                NoteToolbarButton(
                  icon: Icons.title,
                  tooltip: 'Heading',
                  isActive: isFormatActive(Attribute.h1),
                  onTap: () => onToggleFormat(Attribute.h1),
                ),
                NoteToolbarButton(
                  icon: Icons.format_bold,
                  tooltip: 'Bold',
                  isActive: isFormatActive(Attribute.bold),
                  onTap: () => onToggleFormat(Attribute.bold),
                ),
                NoteToolbarButton(
                  icon: Icons.format_italic,
                  tooltip: 'Italic',
                  isActive: isFormatActive(Attribute.italic),
                  onTap: () => onToggleFormat(Attribute.italic),
                ),
                NoteToolbarButton(
                  icon: Icons.link,
                  tooltip: 'Add link',
                  isActive: hasLink,
                  onTap: onAddLink,
                ),
                NoteToolbarButton(
                  icon: Icons.checklist,
                  tooltip: 'Checklist',
                  isActive: isFormatActive(Attribute.unchecked),
                  onTap: () => onToggleFormat(Attribute.unchecked),
                ),
                NoteToolbarButton(
                  icon: Icons.format_list_bulleted,
                  tooltip: 'Bulleted list',
                  isActive: isFormatActive(Attribute.ul),
                  onTap: () => onToggleFormat(Attribute.ul),
                ),
                NoteToolbarButton(
                  icon: Icons.format_list_numbered,
                  tooltip: 'Numbered list',
                  isActive: isFormatActive(Attribute.ol),
                  onTap: () => onToggleFormat(Attribute.ol),
                ),
                NoteToolbarButton(
                  icon: Icons.format_quote,
                  tooltip: 'Quote',
                  isActive: isFormatActive(Attribute.blockQuote),
                  onTap: () => onToggleFormat(Attribute.blockQuote),
                ),
                NoteToolbarButton(
                  icon: Icons.code,
                  tooltip: 'Inline code',
                  isActive: isFormatActive(Attribute.inlineCode),
                  onTap: () => onToggleFormat(Attribute.inlineCode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
