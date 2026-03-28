import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/nps_card.dart';
import '../../../../shared/widgets/rupee_display.dart';
import '../../../../features/onboarding/presentation/onboarding_provider.dart';

/// Two side-by-side stat cards showing corpus and contribution.
class QuickStatsRow extends ConsumerWidget {
  const QuickStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);

    final currentCorpus = onboarding.currentCorpus ?? 0.0;
    final employeeContrib = onboarding.monthlyEmployeeContribution ?? 0.0;
    final employerContrib = onboarding.monthlyEmployerContribution ?? 0.0;
    final monthlyContrib = employeeContrib + employerContrib;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Current Corpus',
            valueWidget: currentCorpus > 0
                ? RupeeDisplay(
                    amount: currentCorpus,
                    size: RupeeDisplaySize.medium,
                  )
                : Text('—', style: AppTypography.amountMedium),
            bottomText: monthlyContrib > 0
                ? '+₹${_compact(monthlyContrib)}/mo'
                : '—',
            bottomColor: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'You contribute',
            valueWidget: monthlyContrib > 0
                ? RupeeDisplay(
                    amount: monthlyContrib,
                    size: RupeeDisplaySize.medium,
                  )
                : Text('—', style: AppTypography.amountMedium),
            bottomText: 'Employee + Employer',
            bottomColor: AppColors.textSecondary,
            tertiaryText: monthlyContrib > 0
                ? '₹${_formatAmount(employeeContrib)} + ₹${_formatAmount(employerContrib)}'
                : null,
          ),
        ),
      ],
    );
  }

  String _compact(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }

  String _formatAmount(double amount) {
    // Basic comma formatting for stats like 4500 -> 4,500
    final parts = amount.toStringAsFixed(0).split('');
    final formatted = <String>[];
    for (int i = 0; i < parts.length; i++) {
      int reversedIndex = parts.length - 1 - i;
      formatted.add(parts[i]);
      if (reversedIndex == 3 ||
          (reversedIndex > 3 && (reversedIndex - 3) % 2 == 0)) {
        formatted.add(',');
      }
    }
    return formatted.join('');
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final Widget valueWidget;
  final String bottomText;
  final Color bottomColor;
  final String? tertiaryText;

  const _StatCard({
    required this.label,
    required this.valueWidget,
    required this.bottomText,
    required this.bottomColor,
    this.tertiaryText,
  });

  @override
  Widget build(BuildContext context) {
    return NPSCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: 6),
          valueWidget,
          const SizedBox(height: 6),
          Text(
            bottomText,
            style: AppTypography.bodySmall.copyWith(color: bottomColor),
          ),
          if (tertiaryText != null) ...[
            const SizedBox(height: 2),
            Text(
              tertiaryText!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
