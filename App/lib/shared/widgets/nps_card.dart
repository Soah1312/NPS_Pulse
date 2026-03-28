import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Base card widget used everywhere in NPS Pulse.
/// Enforces consistent card styling across the app.
class NPSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final Gradient? gradient;

  const NPSCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.showBorder = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding ?? const EdgeInsets.all(AppSpacing.cardPadding);
    final effectiveBgColor = backgroundColor ?? AppColors.backgroundSecondary;

    Widget cardContent = Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: gradient == null ? effectiveBgColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: showBorder
            ? Border.all(color: AppColors.borderSubtle, width: 1)
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }

    return cardContent;
  }
}
