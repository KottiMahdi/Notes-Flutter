import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

import '../error/app_logger.dart';

class NoteContentCodec {
  static const _deltaPrefix = 'quill_delta_v1:';

  static Document decode(String content) {
    if (content.startsWith(_deltaPrefix)) {
      try {
        final decoded = jsonDecode(content.substring(_deltaPrefix.length));
        if (decoded is List) return Document.fromJson(decoded);
      } catch (error, stackTrace) {
        AppLogger.error(
          'Could not decode saved note; treating it as legacy plain text.',
          error: error,
          stackTrace: stackTrace,
          name: 'note_codec',
        );
      }
    }

    final legacyText = content.endsWith('\n') ? content : '$content\n';
    return Document.fromJson([
      {'insert': legacyText},
    ]);
  }

  static String encode(Document document) {
    return '$_deltaPrefix${jsonEncode(document.toDelta().toJson())}';
  }

  static String plainText(String content) {
    if (!content.startsWith(_deltaPrefix)) return content;
    return _withoutFinalNewline(decode(content).toPlainText());
  }

  static String documentPlainText(Document document) {
    return _withoutFinalNewline(document.toPlainText());
  }

  static String _withoutFinalNewline(String text) {
    return text.endsWith('\n') ? text.substring(0, text.length - 1) : text;
  }
}
