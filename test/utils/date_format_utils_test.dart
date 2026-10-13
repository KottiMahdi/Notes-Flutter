import 'package:flutter_test/flutter_test.dart';
import 'package:notes_management_mobile_application/core/utils/date_format_utils.dart';

void main() {
  group('DateFormatUtils', () {
    test('returns "Just now" when dateTime is null', () {
      expect(DateFormatUtils.formatTimestamp(null), 'Just now');
    });

    test('formats AM times correctly', () {
      final dt = DateTime(2026, 1, 15, 9, 5);
      expect(DateFormatUtils.formatTimestamp(dt), 'Jan 15, 9:05 AM');
    });

    test('formats PM times correctly', () {
      final dt = DateTime(2026, 10, 13, 14, 30);
      expect(DateFormatUtils.formatTimestamp(dt), 'Oct 13, 2:30 PM');
    });

    test('formats 12:00 PM correctly', () {
      final dt = DateTime(2026, 7, 4, 12, 0);
      expect(DateFormatUtils.formatTimestamp(dt), 'Jul 4, 12:00 PM');
    });

    test('formats 12:00 AM (midnight) correctly', () {
      final dt = DateTime(2026, 12, 31, 0, 0);
      expect(DateFormatUtils.formatTimestamp(dt), 'Dec 31, 12:00 AM');
    });
  });
}
