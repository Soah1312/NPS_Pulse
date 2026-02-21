import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/rupee_display.dart';

class TierSelector extends ConsumerWidget {
  final String selectedTier;
  final Function(String) onSelect;

  const TierSelector({
    super.key,
    required this.selectedTier,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Retirement Style', style: AppTypography.labelLarge),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTierCard(
                context: context,
                emoji: '🏡',
                name: 'Essential',
                tierKey: 'essential',
                baseAmount: 35000,
              ),
              const SizedBox(width: 12),
              _buildTierCard(
                context: context,
                emoji: '⭐',
                name: 'Comfortable',
                tierKey: 'comfortable',
                baseAmount: 80000,
              ),
              const SizedBox(width: 12),
              _buildTierCard(
                context: context,
                emoji: '👑',
                name: 'Lavish',
                tierKey: 'lavish',
                baseAmount: 200000,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTierCard({
    required BuildContext context,
    required String emoji,
    required String name,
    required String tierKey,
    required double baseAmount,
  }) {
    final isSelected = selectedTier == tierKey;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          onSelect(tierKey);
        }
      },
      child: Container(
        height: 100,
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.backgroundTertiary
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accentAmber : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            RupeeDisplay(
              amount: baseAmount,
              size: RupeeDisplaySize.small,
              color: isSelected ? AppColors.accentAmber : AppColors.textPrimary,
            ),
            Text(
              'base starting rate',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textDisabled,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
