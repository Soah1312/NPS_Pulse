import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/rupee_display.dart';

class TaxLeakageBanner extends StatelessWidget {
  final double taxLeakage;

  const TaxLeakageBanner({super.key, required this.taxLeakage});

  @override
  Widget build(BuildContext context) {
    if (taxLeakage > 0) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF3D1515), // danger-muted
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.danger,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'You\'re losing ',
                        style: AppTypography.headingSmall.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                      RupeeDisplay(
                        amount: taxLeakage,
                        size: RupeeDisplaySize.medium,
                        color: AppColors.danger,
                      ),
                      Text(
                        ' in taxes',
                        style: AppTypography.headingSmall.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'annually that you don\'t have to pay',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Your NPS deductions are fully optimized!',
                  style: AppTypography.headingSmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
