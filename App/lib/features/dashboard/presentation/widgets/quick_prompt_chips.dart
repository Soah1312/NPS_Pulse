import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// Horizontally scrollable suggestion chip row for the AI assistant.
class QuickPromptChips extends StatelessWidget {
  final void Function(String prompt) onChipTapped;

  const QuickPromptChips({super.key, required this.onChipTapped});

  static const List<String> _prompts = [
    'Can I withdraw early?',
    'What\'s my tax saving?',
    'Explain Tier II NPS',
    'Best fund for my age',
    'How is my score calculated?',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: _prompts.map((prompt) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChipTapped(prompt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  border: Border.all(color: AppColors.borderMedium, width: 1),
                ),
                child: Text(
                  prompt,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
