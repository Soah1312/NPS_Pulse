import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/nps_text_field.dart';
import '../onboarding_provider.dart';

/// Step 3: Monthly Salary with live annual CTC chip
class Step3Salary extends ConsumerStatefulWidget {
  const Step3Salary({super.key});

  @override
  ConsumerState<Step3Salary> createState() => _Step3SalaryState();
}

class _Step3SalaryState extends ConsumerState<Step3Salary> {
  late TextEditingController _salaryController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _salaryController = TextEditingController(
      text: state.monthlySalary != null
          ? state.monthlySalary!.round().toString()
          : '',
    );
  }

  @override
  void dispose() {
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salary = ref.watch(onboardingProvider).monthlySalary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            "What's your\nmonthly salary?",
            style: AppTypography.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Used to calculate your tax deductions and NPS contribution limits',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          NPSTextField(
            label: 'Monthly take-home (CTC)',
            hint: 'e.g. 75,000',
            prefixText: '₹ ',
            controller: _salaryController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final cleaned = value.replaceAll(',', '').replaceAll(' ', '');
              final parsed = double.tryParse(cleaned);
              ref.read(onboardingProvider.notifier).updateMonthlySalary(parsed);
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Live annual CTC chip
          if (salary != null && salary > 0)
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.accentBlue,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Annual CTC: ${CurrencyFormatter.formatCompact(salary * 12)}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
