import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/nps_card.dart';
import '../../../../shared/widgets/rupee_display.dart';
import '../../../../shared/widgets/nps_button.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/presentation/widgets/ai_assistant_sheet.dart';
import '../providers/tax_shield_provider.dart';

class ActionItem {
  final String title;
  final String description;
  final double annualSaving;
  final String? noteText;
  final List<ActionChipData>? chips;
  final String? rightActionLabel;
  final VoidCallback? onRightAction;

  ActionItem({
    required this.title,
    required this.description,
    required this.annualSaving,
    this.noteText,
    this.chips,
    this.rightActionLabel,
    this.onRightAction,
  });
}

class ActionChipData {
  final String label;
  final String promptContext;

  ActionChipData(this.label, this.promptContext);
}

class ActionPlanSheet extends ConsumerStatefulWidget {
  const ActionPlanSheet({super.key});

  @override
  ConsumerState<ActionPlanSheet> createState() => _ActionPlanSheetState();
}

class _ActionPlanSheetState extends ConsumerState<ActionPlanSheet> {
  void _openAIAssistant(
    BuildContext context,
    TaxShieldState state,
    String promptContext,
  ) {
    Navigator.pop(context); // Close action plan sheet first

    final contextMessage =
        "User is viewing their Action Plan. Their profile:\n"
        "Annual salary ₹${state.annualSalary}, sector ${state.sector}, regime ${state.taxRegime},\n"
        "80CCD(1) utilized ₹${state.utilized80CCD1} of ₹${state.maxSection80CCD1} max,\n"
        "80CCD(1B) utilized ₹${state.utilized80CCD1B} of ₹50,000 max,\n"
        "80CCD(2) utilized ₹${state.utilized80CCD2} of ₹${state.max80CCD2} max,\n"
        "Total tax leakage ₹${state.taxLeakage}.\n\n"
        "Specific user intent: $promptContext\n"
        "Answer their query with relevance to their tax situation.";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AIAssistantSheet(initialContext: contextMessage),
    );
  }

  List<ActionItem> _generateActionItems(
    BuildContext context,
    TaxShieldState state,
  ) {
    final List<ActionItem> items = [];

    // ACTION A — Maximize 80CCD(1B)
    if (state.potential80CCD1B > 0) {
      double excessEmployeeContribution =
          state.annualEmployeeContribution -
          state.utilized80CCD1 -
          state.utilized80CCD1B;
      if (excessEmployeeContribution < 0) excessEmployeeContribution = 0;

      final int requiredExtraMonthly =
          ((state.potential80CCD1B - excessEmployeeContribution) / 12).ceil();
      final double annualSaving = state.potential80CCD1B * state.marginalRate;

      if (annualSaving > 0) {
        items.add(
          ActionItem(
            title:
                "Increase NPS contribution by ${CurrencyFormatter.formatFull(requiredExtraMonthly.toDouble())}/month",
            description:
                "This fully utilizes your exclusive ₹50,000 80CCD(1B) deduction — completely separate from your 80C limit. Most people miss this entirely.",
            annualSaving: annualSaving,
            noteText:
                "💡 This single change could be worth ${CurrencyFormatter.formatFull(annualSaving)} in your pocket this year",
          ),
        );
      }
    }

    // ACTION B — Regime Switch
    if (state.taxRegime.isNotEmpty &&
        state.taxRegime != state.recommendedRegime &&
        state.regimeSaving > 0) {
      final isSwitchingToNew = state.recommendedRegime == 'new';

      items.add(
        ActionItem(
          title: "Switch to ${isSwitchingToNew ? 'New' : 'Old'} tax regime",
          description: isSwitchingToNew
              ? "Your income and deduction profile means the new regime's lower slabs save you more. Inform your employer's HR/payroll team at the start of the financial year."
              : "Your NPS and other deductions exceed the threshold where old regime wins. Declare your investments to your employer to activate this saving.",
          annualSaving: state.regimeSaving,
          noteText:
              "⚠️ Regime changes take effect from next financial year. Act before April.",
        ),
      );
    }

    // ACTION C — Fill 80C capacity
    double remaining80CCapacity =
        150000 -
        state.otherSection80CInvestments -
        state.effective80CCD1Benefit;
    if (remaining80CCapacity > 10000 && state.taxRegime == 'old') {
      final double annualSaving = remaining80CCapacity * state.marginalRate;

      if (annualSaving > 0) {
        items.add(
          ActionItem(
            title:
                "Invest ${CurrencyFormatter.formatFull(remaining80CCapacity)} more in 80C instruments",
            description:
                "You have unused 80C capacity. ELSS mutual funds give market-linked returns with a 3-year lock-in and qualify for this deduction. PPF offers guaranteed 7.1% returns with full tax-free maturity.",
            annualSaving: annualSaving,
            chips: [
              ActionChipData(
                "ELSS Funds",
                "Tell me about ELSS funds for tax saving under 80C",
              ),
              ActionChipData(
                "PPF",
                "Tell me about PPF for tax saving under 80C",
              ),
            ],
          ),
        );
      }
    }

    // ACTION E — Maximize employer NPS contribution
    if (state.available80CCD2 > 0) {
      final double annualSaving = state.available80CCD2 * state.marginalRate;
      if (annualSaving > 0) {
        items.add(
          ActionItem(
            title: "Request employer to maximize NPS contribution",
            description:
                "Your employer can contribute up to 14% of your basic salary to your NPS account. This is deductible for them as a business expense and tax-free for you — a win-win. Raise this with your HR.",
            annualSaving: annualSaving,
          ),
        );
      }
    }

    // Sort items by highest annual saving first
    items.sort((a, b) => b.annualSaving.compareTo(a.annualSaving));

    // ACTION D — Health Insurance 80D (Always show, no precise annualSaving)
    items.add(
      ActionItem(
        title: "Add health insurance for 80D deduction",
        description:
            "Health insurance premiums are deductible up to ₹25,000 for self/family and an additional ₹25,000-₹50,000 for parents. Available in both regimes.",
        annualSaving: 0, // Differentiator to show 'Up to ₹7,800+'
        rightActionLabel: "Ask Co-Pilot →",
        onRightAction: () => _openAIAssistant(
          context,
          state,
          "Tell me about health insurance deduction under Section 80D",
        ),
      ),
    );

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taxShieldProvider);
    final actionItems = _generateActionItems(context, state);
    final calculableItems = actionItems
        .where((item) => item.annualSaving > 0)
        .toList();

    final double totalPotentialSaving = calculableItems.fold(
      0.0,
      (sum, item) => sum + item.annualSaving,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Action Plan',
                            style: AppTypography.headingMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ranked by tax saving potential',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Save ',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: totalPotentialSaving,
                            ),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return RupeeDisplay(
                                amount: value,
                                size: RupeeDisplaySize.small,
                                color: AppColors.success,
                                showFullAmount: true,
                              );
                            },
                          ),
                          Text(
                            '/yr',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.borderSubtle, height: 1),

              // Content
              Expanded(
                child: calculableItems.isEmpty
                    ? _buildEmptyState(context, state)
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: actionItems.length + 1, // +1 for disclaimer
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == actionItems.length) {
                            return _buildDisclaimer();
                          }
                          return ActionItemCard(
                            item: actionItems[index],
                            index: index,
                            state: state,
                            onOpenAssistant: _openAIAssistant,
                            totalCalculableItems: calculableItems.length,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, TaxShieldState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 24),
          Text('You\'re fully optimized!', style: AppTypography.headingMedium),
          const SizedBox(height: 8),
          Text(
            'Your NPS tax deductions are maximized. Keep contributing consistently and review again next financial year.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          NPSButton(
            label: "Ask Co-Pilot for more tips →",
            onPressed: () => _openAIAssistant(
              context,
              state,
              "Are there any advanced tax saving strategies for salaried employees?",
            ),
            variant: NPSButtonVariant.ghost,
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '📋 These are estimates based on your NPS data and standard tax rules for FY 2024-25. Consult a qualified tax advisor (CA) before making financial decisions. Tax laws may change.',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textDisabled),
      ),
    );
  }
}

class ActionItemCard extends StatelessWidget {
  final ActionItem item;
  final int index;
  final TaxShieldState state;
  final void Function(BuildContext, TaxShieldState, String) onOpenAssistant;
  final int totalCalculableItems;

  const ActionItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.state,
    required this.onOpenAssistant,
    required this.totalCalculableItems,
  });

  @override
  Widget build(BuildContext context) {
    // Only animate on init, not strictly required for standard Stateless but we can use TweenAnimationBuilder to simulate FadeTransition
    final bool isHealthInsurance = item.annualSaving == 0;

    // Rank Number Circle colors
    Color circleBg = AppColors.backgroundTertiary;
    Color numColor = AppColors.textSecondary;
    if (index == 0 && !isHealthInsurance) {
      circleBg = AppColors.accentAmber;
      numColor = AppColors.backgroundPrimary;
    } else if (index == 1 && !isHealthInsurance) {
      circleBg = AppColors.accentBlue;
      numColor = AppColors.backgroundPrimary;
    }

    final int rankNumber = isHealthInsurance
        ? totalCalculableItems + 1
        : index + 1;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      // Delay stagger based on index
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: NPSCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ranking number circle
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: circleBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$rankNumber',
                    style: AppTypography.labelLarge.copyWith(color: numColor),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Center column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: AppTypography.headingSmall),
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isHealthInsurance)
                      Row(
                        children: [
                          Text(
                            'You save: ',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          RupeeDisplay(
                            amount: item.annualSaving,
                            size: RupeeDisplaySize.small,
                            color: AppColors.success,
                            showFullAmount: true,
                          ),
                          Text(
                            '/yr',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),

                    if (item.noteText != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.noteText!.startsWith('💡')
                              ? AppColors.accentAmber.withValues(alpha: 0.08)
                              : Colors.transparent,
                          border: Border.all(
                            color: item.noteText!.startsWith('💡')
                                ? AppColors.accentAmber.withValues(alpha: 0.2)
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.noteText!,
                          style: AppTypography.bodySmall.copyWith(
                            color: item.noteText!.startsWith('⚠️')
                                ? AppColors.warning
                                : AppColors.accentAmber,
                          ),
                        ),
                      ),
                    ],

                    if (item.chips != null) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: item.chips!
                            .map(
                              (chip) => GestureDetector(
                                onTap: () => onOpenAssistant(
                                  context,
                                  state,
                                  chip.promptContext,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundTertiary,
                                    border: Border.all(
                                      color: AppColors.borderMedium,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    chip.label,
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Right Column
              if (isHealthInsurance)
                TextButton(
                  onPressed: item.onRightAction,
                  child: Text(
                    item.rightActionLabel ?? '',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accentAmber,
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RupeeDisplay(
                      amount: item.annualSaving,
                      size: RupeeDisplaySize.small,
                      showFullAmount: true,
                    ),
                    Text(
                      'saved/yr',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
