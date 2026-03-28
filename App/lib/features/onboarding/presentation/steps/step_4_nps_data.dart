import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/nps_text_field.dart';
import '../onboarding_provider.dart';

/// Step 4: NPS Data — corpus and contributions with skip option
class Step4NpsData extends ConsumerStatefulWidget {
  /// Callback when user taps "Skip for now"
  final VoidCallback? onSkip;

  const Step4NpsData({super.key, this.onSkip});

  @override
  ConsumerState<Step4NpsData> createState() => _Step4NpsDataState();
}

class _Step4NpsDataState extends ConsumerState<Step4NpsData> {
  late TextEditingController _corpusController;
  late TextEditingController _employeeController;
  late TextEditingController _employerController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _corpusController = TextEditingController(
      text: state.currentCorpus != null && state.currentCorpus! > 0
          ? state.currentCorpus!.round().toString()
          : '',
    );
    _employeeController = TextEditingController(
      text:
          state.monthlyEmployeeContribution != null &&
              state.monthlyEmployeeContribution! > 0
          ? state.monthlyEmployeeContribution!.round().toString()
          : '',
    );
    _employerController = TextEditingController(
      text:
          state.monthlyEmployerContribution != null &&
              state.monthlyEmployerContribution! > 0
          ? state.monthlyEmployerContribution!.round().toString()
          : '',
    );
  }

  @override
  void dispose() {
    _corpusController.dispose();
    _employeeController.dispose();
    _employerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Text('Tell us about\nyour NPS', style: AppTypography.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Check your NPS account on the NSDL portal or your salary slip',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          NPSTextField(
            label: 'Current NPS corpus (Tier I)',
            prefixText: '₹ ',
            controller: _corpusController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsed = double.tryParse(value.replaceAll(',', ''));
              ref.read(onboardingProvider.notifier).updateCurrentCorpus(parsed);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          NPSTextField(
            label: 'Monthly employee contribution',
            prefixText: '₹ ',
            controller: _employeeController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsed = double.tryParse(value.replaceAll(',', ''));
              ref
                  .read(onboardingProvider.notifier)
                  .updateMonthlyEmployeeContribution(parsed);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          NPSTextField(
            label: 'Monthly employer contribution',
            hint: 'Optional',
            prefixText: '₹ ',
            controller: _employerController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final parsed = double.tryParse(value.replaceAll(',', ''));
              ref
                  .read(onboardingProvider.notifier)
                  .updateMonthlyEmployerContribution(parsed);
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Info card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ℹ️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    "Not sure? Enter 0 for now. You can update this anytime from your profile.",
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
