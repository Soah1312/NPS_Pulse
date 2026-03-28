import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/nps_card.dart';
import '../../../../shared/widgets/rupee_display.dart';

class RegimeComparisonCard extends StatelessWidget {
  final double oldRegimeTax;
  final double newRegimeTax;
  final String recommendedRegime;
  final double regimeSaving;
  final String currentRegime;
  final double annualSalary;

  const RegimeComparisonCard({
    super.key,
    required this.oldRegimeTax,
    required this.newRegimeTax,
    required this.recommendedRegime,
    required this.regimeSaving,
    required this.currentRegime,
    required this.annualSalary,
  });

  Widget _buildRegimeCol(
    BuildContext context,
    String title,
    double tax,
    bool isRecommended,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelLarge),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: tax),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return RupeeDisplay(amount: value, size: RupeeDisplaySize.medium);
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Tax payable',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (title == 'New Regime' && tax == 0 && annualSalary <= 750000) ...[
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) =>
                  Opacity(opacity: value, child: child),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '₹0 via Section 87A rebate',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  if (annualSalary > 700000) ...[
                    const SizedBox(height: 6),
                    Tooltip(
                      message:
                          "Since your income is close to ₹7L, marginal relief ensures your tax doesn't exceed your income above ₹7,00,000",
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      textStyle: AppTypography.bodySmall.copyWith(
                        color: AppColors.backgroundPrimary,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Marginal relief applied ',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (isRecommended) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Recommended ✓',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text('', style: AppTypography.labelSmall),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NPSCard(
      backgroundColor: AppColors.backgroundTertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Which regime saves you more?',
            style: AppTypography.headingSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRegimeCol(
                context,
                'Old Regime',
                oldRegimeTax,
                recommendedRegime == 'old',
              ),
              Container(
                width: 1,
                height: 80,
                color: AppColors.borderSubtle,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _buildRegimeCol(
                context,
                'New Regime',
                newRegimeTax,
                recommendedRegime == 'new',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: AppSpacing.lg),

          if (currentRegime == recommendedRegime &&
              currentRegime.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'re already on the optimal regime',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Switching to ${recommendedRegime == 'old' ? 'Old' : 'New'} saves you ',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: regimeSaving),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return RupeeDisplay(
                      amount: value,
                      size: RupeeDisplaySize.large,
                      color: AppColors.success,
                    );
                  },
                ),
                Text(
                  ' annually',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          Text(
            'Estimate based on NPS contributions only. Consult a tax advisor for complete tax planning.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
