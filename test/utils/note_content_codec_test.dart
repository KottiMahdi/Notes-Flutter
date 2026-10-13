import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/core/utils/note_content_codec.dart';

void main() {
  group('NoteContentCodec', () {
    test('opens legacy plain-text notes unchanged', () {
      final document = NoteContentCodec.decode('Legacy note');

      expect(NoteContentCodec.documentPlainText(document), 'Legacy note');
      document.close();
    });

    test('round-trips formatting and list attributes', () {
      final controller = QuillController(
        document: NoteContentCodec.decode('Formatted note'),
        selection: const TextSelection(baseOffset: 0, extentOffset: 14),
      );
      controller.formatSelection(Attribute.bold);
      controller.formatSelection(Attribute.italic);
      controller.formatSelection(Attribute.ul);

      final encoded = NoteContentCodec.encode(controller.document);
      final reopened = NoteContentCodec.decode(encoded);
      final styles = reopened.collectStyle(0, 14).attributes;

      expect(NoteContentCodec.documentPlainText(reopened), 'Formatted note');
      expect(styles[Attribute.bold.key]?.value, isTrue);
      expect(styles[Attribute.italic.key]?.value, isTrue);
      expect(styles[Attribute.list.key]?.value, 'bullet');

      controller.formatSelection(Attribute.ol);
      final numberedList = NoteContentCodec.decode(
        NoteContentCodec.encode(controller.document),
      );
      expect(
        numberedList.collectStyle(0, 14).attributes[Attribute.list.key]?.value,
        'ordered',
      );

      controller.dispose();
      reopened.close();
      numberedList.close();
    });

    test('collapsed cursor formatting applies to upcoming text', () {
      final controller = QuillController(
        document: Document(),
        selection: const TextSelection.collapsed(offset: 0),
      );
      controller.formatSelection(Attribute.bold);
      controller.formatSelection(Attribute.italic);
      controller.replaceText(
        0,
        0,
        'New text',
        const TextSelection.collapsed(offset: 8),
      );

      final styles = controller.document.collectStyle(0, 8).attributes;
      expect(styles[Attribute.bold.key]?.value, isTrue);
      expect(styles[Attribute.italic.key]?.value, isTrue);

      controller.dispose();
    });

    test('Quill history undoes and redoes formatting changes', () {
      final controller = QuillController(
        document: NoteContentCodec.decode('Undo format'),
        selection: const TextSelection(baseOffset: 0, extentOffset: 11),
      );
      controller.formatSelection(Attribute.bold);

      expect(controller.hasUndo, isTrue);
      controller.undo();
      expect(
        controller.document.collectStyle(0, 11).attributes[Attribute.bold.key],
        isNull,
      );

      controller.redo();
      expect(
        controller.document
            .collectStyle(0, 11)
            .attributes[Attribute.bold.key]
            ?.value,
        isTrue,
      );
      controller.dispose();
    });
  });
}
