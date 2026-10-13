import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/core/utils/quill_editor_utils.dart';

void main() {
  group('QuillEditorUtils', () {
    test('returns null when no link is at selection', () {
      final controller = QuillController(
        document: Document.fromJson([
          {'insert': 'Hello world\n'},
        ]),
        selection: const TextSelection.collapsed(offset: 2),
      );

      expect(QuillEditorUtils.linkAtSelection(controller), isNull);
      controller.dispose();
    });

    test('detects link at selection correctly', () {
      final controller = QuillController(
        document: Document.fromJson([
          {'insert': 'Visit '},
          {
            'insert': 'Google',
            'attributes': {'link': 'https://google.com'},
          },
          {'insert': '\n'},
        ]),
        selection: const TextSelection.collapsed(offset: 8),
      );

      final linkInfo = QuillEditorUtils.linkAtSelection(controller);
      expect(linkInfo, isNotNull);
      expect(linkInfo?.url, 'https://google.com');
      expect(linkInfo?.offset, 6);
      expect(linkInfo?.length, 6);

      controller.dispose();
    });

    test('applies link to selected text range', () {
      final controller = QuillController(
        document: Document.fromJson([
          {'insert': 'Flutter Web\n'},
        ]),
        selection: const TextSelection(baseOffset: 0, extentOffset: 7),
      );

      QuillEditorUtils.applyLink(
        controller: controller,
        url: 'https://flutter.dev',
      );

      final linkInfo = QuillEditorUtils.linkAtSelection(controller);
      expect(linkInfo?.url, 'https://flutter.dev');
      expect(linkInfo?.length, 7);

      controller.dispose();
    });

    test('updates existing link when existingLink is provided', () {
      final controller = QuillController(
        document: Document.fromJson([
          {
            'insert': 'Link',
            'attributes': {'link': 'https://old.com'},
          },
          {'insert': '\n'},
        ]),
        selection: const TextSelection.collapsed(offset: 2),
      );

      final existing = QuillEditorUtils.linkAtSelection(controller);
      expect(existing, isNotNull);

      QuillEditorUtils.applyLink(
        controller: controller,
        url: 'https://new.com',
        existingLink: existing,
      );

      final updated = QuillEditorUtils.linkAtSelection(controller);
      expect(updated?.url, 'https://new.com');

      controller.dispose();
    });

    test('removes link when url is null on existingLink', () {
      final controller = QuillController(
        document: Document.fromJson([
          {
            'insert': 'Link',
            'attributes': {'link': 'https://old.com'},
          },
          {'insert': '\n'},
        ]),
        selection: const TextSelection.collapsed(offset: 2),
      );

      final existing = QuillEditorUtils.linkAtSelection(controller);
      expect(existing, isNotNull);

      QuillEditorUtils.applyLink(
        controller: controller,
        url: null,
        existingLink: existing,
      );

      expect(QuillEditorUtils.linkAtSelection(controller), isNull);
      controller.dispose();
    });
  });
}
