import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

enum NPSButtonVariant { primary, secondary, ghost }

/// Button widget with three variants: primary (amber gradient fill),
/// secondary (outline amber), ghost (text only).
class NPSButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final NPSButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;

  const NPSButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NPSButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 52,
      child: _buildVariant(),
    );
  }

  Widget _buildVariant() {
    switch (variant) {
      case NPSButtonVariant.primary:
        return _buildPrimary();
      case NPSButtonVariant.secondary:
        return _buildSecondary();
      case NPSButtonVariant.ghost:
        return _buildGhost();
    }
  }

  Widget _buildPrimary() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientAmberStart, AppColors.gradientAmberEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          child: Center(child: _buildContent(AppColors.backgroundPrimary)),
        ),
      ),
    );
  }

  Widget _buildSecondary() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.accentAmber, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        minimumSize: const Size(48, 48),
      ),
      child: _buildContent(AppColors.accentAmber),
    );
  }

  Widget _buildGhost() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        minimumSize: const Size(48, 48),
      ),
      child: _buildContent(AppColors.accentAmber),
    );
  }

  Widget _buildContent(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    if (leadingIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(leadingIcon, color: contentColor, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.labelLarge.copyWith(color: contentColor),
          ),
        ],
      );
    }

    return Text(
      label,
      style: AppTypography.labelLarge.copyWith(color: contentColor),
    );
  }
}
