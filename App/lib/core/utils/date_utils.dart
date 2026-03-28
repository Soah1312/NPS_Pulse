import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  /// Format date as "12 Jan 2025"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date as "Jan 2025"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMM yyyy').format(date);
  }

  /// Format date as "12/01/2025"
  static String formatDateNumeric(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Get years remaining until a target age
  static int yearsUntil(int currentAge, int targetAge) {
    return targetAge - currentAge;
  }

  /// Get months remaining until a target date
  static int monthsUntilDate(DateTime targetDate) {
    final now = DateTime.now();
    return (targetDate.year - now.year) * 12 + (targetDate.month - now.month);
  }

  /// Format a duration in years and months
  static String formatDuration(int totalMonths) {
    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;
    if (years == 0) return '$months months';
    if (months == 0) return '$years years';
    return '$years years, $months months';
  }
}
