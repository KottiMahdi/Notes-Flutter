class DateFormatUtils {
  const DateFormatUtils._();

  static String formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dateTime.month - 1];
    final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month ${dateTime.day}, $hour12:$minute $period';
  }
}
