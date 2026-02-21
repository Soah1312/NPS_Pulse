import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class InflationVisual extends StatelessWidget {
  final int years;
  final double multiplier;

  const InflationVisual({
    super.key,
    required this.years,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.backgroundSecondary, AppColors.backgroundTertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Inflation Reality Check',
                style: AppTypography.headingSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderMedium),
                ),
                child: Text(
                  '$years years away',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: multiplier),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Column(
                children: [
                  Text(
                    '×${val.toStringAsFixed(1)}',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.accentAmber,
                    ),
                  ),
                  Text(
                    'inflation multiplier',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹1,000 today',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.accentAmber,
                          size: 16,
                        ),
                      ),
                      Text(
                        '₹${(1000 * val).toInt()}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.accentAmber,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'at retirement',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Based on 6% annual inflation rate',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textDisabled,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
