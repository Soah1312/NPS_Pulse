import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/nps_card.dart';
import '../../../shared/widgets/rupee_display.dart';
import '../../../shared/widgets/nps_button.dart';
import '../../dashboard/presentation/widgets/ai_assistant_sheet.dart';
import 'providers/tax_shield_provider.dart';
import 'widgets/tax_leakage_banner.dart';
import 'widgets/other_investments_sheet.dart';
import 'widgets/deduction_section_card.dart';
import 'widgets/regime_comparison_card.dart';
import 'widgets/action_plan_sheet.dart';

class TaxShieldScreen extends ConsumerStatefulWidget {
  const TaxShieldScreen({super.key});

  @override
  ConsumerState<TaxShieldScreen> createState() => _TaxShieldScreenState();
}

class _TaxShieldScreenState extends ConsumerState<TaxShieldScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _regimeComparisonKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showOtherInvestmentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OtherInvestmentsSheet(),
    );
  }

  void _showAiAssistant(BuildContext context, TaxShieldState state) {
    final contextMessage =
        "User is viewing their Tax Shield. Their profile:\n"
        "Annual salary ₹${state.annualSalary}, sector ${state.sector}, regime ${state.taxRegime},\n"
        "80CCD(1) utilized ₹${state.utilized80CCD1} of ₹${state.maxSection80CCD1} max,\n"
        "80CCD(1B) utilized ₹${state.utilized80CCD1B} of ₹50,000 max,\n"
        "80CCD(2) utilized ₹${state.utilized80CCD2} of ₹${state.max80CCD2} max,\n"
        "Total tax leakage ₹${state.taxLeakage}.\n"
        "Answer their tax questions in this context.";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIAssistantSheet(initialContext: contextMessage),
    );
  }

  Widget _buildRegimeToggle(String currentRegime) {
    bool isOld = currentRegime == 'old';
    bool isNew = currentRegime == 'new';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background Pill Layer
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            alignment: isOld ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accentAmber, width: 1.5),
                ),
              ),
            ),
          ),

          // Foreground Text Layer
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (isOld) return; // already old
                    ref
                        .read(taxShieldLocalProvider.notifier)
                        .updateTaxRegime('old', ref);

                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  },
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 280),
                      style: AppTypography.labelLarge.copyWith(
                        color: isOld
                            ? AppColors.accentAmber
                            : AppColors.textSecondary,
                      ),
                      child: const Text('Old Regime'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (isNew) return; // already new
                    ref
                        .read(taxShieldLocalProvider.notifier)
                        .updateTaxRegime('new', ref);

                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (_regimeComparisonKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          _regimeComparisonKey.currentContext!,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          alignment: 0.1,
                        );
                      }
                    });
                  },
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 280),
                      style: AppTypography.labelLarge.copyWith(
                        color: isNew
                            ? AppColors.accentAmber
                            : AppColors.textSecondary,
                      ),
                      child: const Text('New Regime'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taxShieldProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          top: 60,
          bottom: 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Text('Tax Shield', style: AppTypography.headingLarge),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundTertiary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'FY 2024-25',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Based on your salary of ',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                RupeeDisplay(
                  amount: state.annualSalary,
                  size: RupeeDisplaySize.medium,
                  color: AppColors.textSecondary,
                ),
                Text(
                  '/yr',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Leakage Banner
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                );
              },
              child: state.taxRegime.isNotEmpty
                  ? Padding(
                      key: const ValueKey('banner'),
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      child: TaxLeakageBanner(taxLeakage: state.taxLeakage),
                    )
                  : const SizedBox.shrink(key: ValueKey('no_banner')),
            ),

            // Other Investments Secion
            NPSCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your other 80C investments',
                    style: AppTypography.headingSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PPF, ELSS, LIC, home loan principal etc.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (!state.hasEnteredOtherInvestments)
                    TextButton(
                      onPressed: () => _showOtherInvestmentsSheet(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Add investments ',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.accentAmber,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.accentAmber,
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        RupeeDisplay(
                          amount: state.otherSection80CInvestments,
                          size: RupeeDisplaySize.medium,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _showOtherInvestmentsSheet(context),
                          child: Row(
                            children: [
                              Text(
                                'Edit ',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.accentAmber,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: AppColors.accentAmber,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Regime Toggle
            _buildRegimeToggle(state.taxRegime),

            // Content Transition
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: Column(
                key: ValueKey(state.taxRegime),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.taxRegime.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.md,
                        bottom: AppSpacing.xl,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Set your tax regime above to see your personalized deduction analysis',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: AppSpacing.xl),

                  // 80CCD(1) Card
                  DeductionSectionCard(
                    sectionName: '80CCD(1)',
                    plainEnglishTitle: 'Your NPS Contribution',
                    plainEnglishDescription:
                        'Tax deduction on your own NPS contributions. Salaried: up to 10% of Basic salary, max ₹1.5L. Self-employed: up to 20% of gross income, max ₹1.5L. Counts toward the combined ₹1.5L limit with 80C.',
                    maxAmount: state.maxSection80CCD1,
                    utilizedAmount: state.effective80CCD1Benefit,
                    missedAmount: state.available80CCD1,
                    taxSaved: state.effective80CCD1Benefit * state.marginalRate,
                    isAvailableInNewRegime: false,
                    isAvailableInSelectedRegime: state.taxRegime == 'old',
                    currentRegimeName: state.taxRegime,
                  ),

                  // 80CCD(1B) Card
                  DeductionSectionCard(
                    sectionName: '80CCD(1B)',
                    plainEnglishTitle: 'Extra ₹50,000 NPS Deduction',
                    plainEnglishDescription:
                        'An additional ₹50,000 deduction exclusively for NPS — completely separate from and on top of the ₹1.5L 80C limit. This is the most commonly missed tax benefit in India. Only works if you contribute enough to NPS to exceed your 80CCD(1) limit.',
                    maxAmount: state.max80CCD1B,
                    utilizedAmount: state.utilized80CCD1B,
                    missedAmount: state.potential80CCD1B,
                    taxSaved: state.utilized80CCD1B * state.marginalRate,
                    isAvailableInNewRegime: false,
                    isAvailableInSelectedRegime: state.taxRegime == 'old',
                    currentRegimeName: state.taxRegime,
                  ),

                  // 80CCD(2) Card
                  DeductionSectionCard(
                    sectionName: '80CCD(2)',
                    plainEnglishTitle: 'Employer\'s NPS Contribution',
                    plainEnglishDescription:
                        'Tax deduction on your employer\'s NPS contributions to your account. Works in BOTH old and new tax regimes — the only NPS deduction that survives the new regime. Budget 2024 increased the limit to 14% of Basic salary for all employees.',
                    maxAmount: state.max80CCD2,
                    utilizedAmount: state.utilized80CCD2,
                    missedAmount: state.available80CCD2,
                    taxSaved: state.utilized80CCD2 * state.marginalRate,
                    isAvailableInNewRegime: true,
                    isAvailableInSelectedRegime: true, // both
                    currentRegimeName: state.taxRegime,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Regime Comparison
                  if (state.taxRegime.isNotEmpty) ...[
                    Padding(
                      key: _regimeComparisonKey,
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      child: RegimeComparisonCard(
                        oldRegimeTax: state.oldRegimeTax,
                        newRegimeTax: state.newRegimeTax,
                        recommendedRegime: state.recommendedRegime,
                        regimeSaving: state.regimeSaving,
                        currentRegime: state.taxRegime,
                        annualSalary: state.annualSalary,
                      ),
                    ),
                  ],

                  // Action Plan CTA
                  if (state.taxRegime.isNotEmpty) ...[
                    NPSButton(
                      label: 'See Your Action Plan →',
                      leadingIcon: Icons.rocket_launch_outlined,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const ActionPlanSheet(),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // AI Co-Pilot CTA
                  GestureDetector(
                    onTap: () => _showAiAssistant(context, state),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentAmber.withValues(alpha: 0.15),
                            AppColors.accentAmber.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.accentAmber.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Have tax questions?',
                                  style: AppTypography.headingSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ask your NPS Co-Pilot for personalized tax advice based on your situation',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.accentAmber,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
