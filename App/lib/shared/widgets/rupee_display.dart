import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';

enum RupeeDisplaySize { small, medium, large }

/// Formatted ₹ number display widget.
/// Formats amounts in Indian system (lakhs/crores).
///
/// - Below 1 lakh: ₹95,000
/// - 1 lakh to 99 lakh: ₹12.4 L
/// - 1 crore and above: ₹1.2 Cr
/// - Full mode uses Indian comma system: ₹1,24,50,000
class RupeeDisplay extends StatelessWidget {
  final double amount;
  final RupeeDisplaySize size;
  final Color? color;
  final bool showFullAmount;

  const RupeeDisplay({
    super.key,
    required this.amount,
    this.size = RupeeDisplaySize.medium,
    this.color,
    this.showFullAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayColor = color ?? AppColors.accentAmber;
    final text = showFullAmount
        ? CurrencyFormatter.formatFull(amount)
        : CurrencyFormatter.formatCompact(amount);

    TextStyle style;
    switch (size) {
      case RupeeDisplaySize.small:
        style = AppTypography.amountSmall;
        break;
      case RupeeDisplaySize.medium:
        style = AppTypography.amountMedium;
        break;
      case RupeeDisplaySize.large:
        style = AppTypography.amountLarge;
        break;
    }

    return Text(text, style: style.copyWith(color: displayColor));
  }
}
