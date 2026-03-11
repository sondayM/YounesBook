import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat.yMMMd().format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return DateFormat.yMMMd().add_Hm().format(date);
  }

  static DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  static bool isSameYear(DateTime a, DateTime b) {
    return a.year == b.year;
  }
}
