import 'package:cloud_firestore/cloud_firestore.dart';

class AppDateUtils {
  AppDateUtils._();

  /// Returns date key string in format YYYY-MM-DD
  static String toDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String todayKey() => toDateKey(DateTime.now());

  static String yesterdayKey() =>
      toDateKey(DateTime.now().subtract(const Duration(days: 1)));

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isConsecutiveDay(String prevKey, String currentKey) {
    try {
      final prev = DateTime.parse(prevKey);
      final current = DateTime.parse(currentKey);
      final diff = current.difference(prev).inDays;
      return diff == 1;
    } catch (_) {
      return false;
    }
  }

  static DateTime fromTimestamp(Timestamp timestamp) {
    return timestamp.toDate();
  }

  static Timestamp toTimestamp(DateTime date) {
    return Timestamp.fromDate(date);
  }

  static String formatCountdown(Duration duration) {
    if (duration.isNegative) return 'Event passed';
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  static String formatEventDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
