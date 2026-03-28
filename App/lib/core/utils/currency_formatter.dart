import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats amount in Indian numbering system (lakhs/crores).
  /// Returns abbreviated form: ₹95,000 | ₹12.4 L | ₹1.2 Cr
  static String formatCompact(double amount) {
    if (amount < 0) return '-${formatCompact(-amount)}';

    if (amount >= 10000000) {
      // 1 crore and above
      final crores = amount / 10000000;
      final formatted = crores == crores.roundToDouble()
          ? crores.toStringAsFixed(0)
          : crores.toStringAsFixed(1);
      return '₹$formatted Cr';
    } else if (amount >= 100000) {
      // 1 lakh to 99.9 lakh
      final lakhs = amount / 100000;
      final formatted = lakhs == lakhs.roundToDouble()
          ? lakhs.toStringAsFixed(0)
          : lakhs.toStringAsFixed(1);
      return '₹$formatted L';
    } else {
      // Below 1 lakh
      return '₹${_formatIndianNumber(amount.round())}';
    }
  }

  /// Formats amount with full Indian comma system: ₹1,24,50,000
  static String formatFull(double amount) {
    if (amount < 0) return '-${formatFull(-amount)}';
    return '₹${_formatIndianNumber(amount.round())}';
  }

  /// Indian comma system: 1,24,50,000
  static String _formatIndianNumber(int number) {
    if (number < 1000) return number.toString();

    final str = number.toString();
    final len = str.length;

    // Last 3 digits
    String result = str.substring(len - 3);

    // Remaining digits in groups of 2
    final prefix = str.substring(0, len - 3);

    // Work from right to left on the remaining digits
    final prefixLen = prefix.length;
    if (prefixLen > 0) {
      List<String> groups = [];
      int i = prefixLen;
      while (i > 0) {
        final start = (i - 2) < 0 ? 0 : i - 2;
        groups.insert(0, prefix.substring(start, i));
        i = start;
      }
      result = '${groups.join(',')},$result';
    }

    return result;
  }

  /// Format with NumberFormat for simple cases
  static String formatSimple(double amount) {
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return '₹${formatter.format(amount.round())}';
  }
}
