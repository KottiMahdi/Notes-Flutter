import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

typedef LinkSelectionInfo = ({int offset, int length, String url});

class QuillEditorUtils {
  const QuillEditorUtils._();

  static LinkSelectionInfo? linkAtSelection(QuillController controller) {
    final selection = controller.selection;
    final base = selection.start;
    final candidates = selection.isCollapsed ? [base, base - 1] : [base];
    for (final position in candidates) {
      if (position < 0 || position >= controller.document.length) continue;
      final lineQuery = controller.document.queryChild(position);
      final line = lineQuery.node;
      if (line is! Line) continue;
      final node = line.queryChild(lineQuery.offset, false).node;
      if (node is! Leaf) continue;
      final link = node.style.attributes[Attribute.link.key]?.value;
      if (link is String && link.isNotEmpty) {
        return (offset: node.documentOffset, length: node.length, url: link);
      }
    }
    return null;
  }

  static void applyLink({
    required QuillController controller,
    required String? url,
    LinkSelectionInfo? existingLink,
  }) {
    if (existingLink != null) {
      controller.formatText(
        existingLink.offset,
        existingLink.length,
        Attribute.clone(Attribute.link, url),
      );
      return;
    }

    if (url == null || url.isEmpty) return;

    final linkAttribute = Attribute.clone(Attribute.link, url);
    final selection = controller.selection;
    if (selection.isCollapsed) {
      final start = selection.extentOffset;
      controller.replaceText(
        start,
        0,
        url,
        TextSelection.collapsed(offset: start + url.length),
      );
      controller.formatText(start, url.length, linkAttribute);
    } else {
      controller.formatText(
        selection.start,
        selection.end - selection.start,
        linkAttribute,
      );
    }
  }
}
