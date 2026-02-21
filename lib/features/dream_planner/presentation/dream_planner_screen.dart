import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/nps_button.dart';
import '../../../shared/widgets/rupee_display.dart';
import '../../dashboard/presentation/providers/dashboard_provider.dart';

import 'providers/dream_planner_provider.dart';
import 'widgets/tier_selector.dart';
import 'widgets/inflation_visual.dart';
import 'widgets/lifestyle_category_card.dart';
import 'widgets/category_edit_sheet.dart';
import '../../../../shared/models/lifestyle_goal.dart';

class DreamPlannerScreen extends ConsumerWidget {
  const DreamPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(dreamPlannerProvider);
    final isSaving = s.isSaving;
    final dashboard = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            top: AppSpacing.lg,
            bottom: 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECTION 1 — Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Retirement Dream',
                        style: AppTypography.headingLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'What you\'re working toward',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (isSaving)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // SECTION 2 — Tier Selector
              TierSelector(
                selectedTier: s.tierName,
                onSelect: (newTier) =>
                    _showSwitchTierDialog(context, ref, newTier),
              ),
              const SizedBox(height: 32),

              // SECTION 3 — Inflation Visual
              InflationVisual(
                years: s.targetRetirementAge - s.age <= 0
                    ? 1
                    : s.targetRetirementAge - s.age,
                multiplier: s.inflationMultiplier,
              ),
              const SizedBox(height: 32),

              // SECTION 4 — Category Breakdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Monthly Breakdown', style: AppTypography.headingSmall),
                  Text(
                    'Edit any category →',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ...s.lineItems.map((g) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LifestyleCategoryCard(
                    categoryId: g.id,
                    emoji: g.emoji,
                    label: g.label,
                    amountToday: g.monthlyAmountToday,
                    futureAmount:
                        g.monthlyAmountToday *
                        s.inflationMultiplier, // Simple uniform mapping here due to limited space for unique rates in visual
                    multiplier: s
                        .inflationMultiplier, // we track a localized one under the hood if needed.
                    onEditTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CategoryEditSheet(
                          categoryId: g.id,
                          emoji: g.emoji,
                          label: g.label,
                          currentAmount: g.monthlyAmountToday,
                          inflationRate: g.inflationRate,
                          inflationMultiplier: s.inflationMultiplier,
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 32),

              // SECTION 5 — Total Summary Card
              _buildTotalSummaryCard(context, s, dashboard.projectedCorpus),
              const SizedBox(height: 24),

              // SECTION 6 — Action CTA
              _buildActionCTA(context),
            ],
          ),
        ),
      ),
    );
  }

  void _showSwitchTierDialog(
    BuildContext context,
    WidgetRef ref,
    String newTier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: Text(
          'Switch to $newTier plan?',
          style: AppTypography.headingSmall,
        ),
        content: Text(
          'This will reset your lifestyle categories to $newTier defaults. Your customizations will be lost.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          NPSButton(
            label: 'Cancel',
            variant: NPSButtonVariant.ghost,
            onPressed: () => Navigator.pop(context),
          ),
          NPSButton(
            label: 'Switch',
            onPressed: () {
              // Map dummy defaults just to prove the switch
              final mockDefaults = _getMockDefaultsForTier(newTier);
              ref
                  .read(dreamPlannerProvider.notifier)
                  .switchTier(newTier, mockDefaults);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSummaryCard(
    BuildContext context,
    dynamic s,
    double currentCorpus,
  ) {
    final requiredCorpus =
        s.totalMonthlyAtRetirement *
        12 *
        25; // Simple 25-year withdrawal assumption from user rules
    final progress = requiredCorpus > 0
        ? (currentCorpus / requiredCorpus).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentAmber, width: 1.5),
        color: AppColors.backgroundSecondary,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Your Total Retirement Need', style: AppTypography.headingSmall),
          const SizedBox(height: 16),

          // Today Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RupeeDisplay(
                          amount: s.totalMonthlyToday,
                          size: RupeeDisplaySize.medium,
                          color: AppColors.accentAmber,
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '/month',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: -10, end: 0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.bounceOut,
                builder: (context, val, child) {
                  return Transform.translate(
                    offset: Offset(0, val),
                    child: const RotationTransition(
                      turns: AlwaysStoppedAnimation(45 / 360),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.accentBlue,
                        size: 28,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Retirement Row
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'At retirement (age ${s.targetRetirementAge})',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RupeeDisplay(
                    amount: s.totalMonthlyAtRetirement,
                    size: RupeeDisplaySize.medium,
                    color: AppColors.accentBlue,
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '/month',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            'That\'s ${s.inflationMultiplier.toStringAsFixed(1)}× more than today',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.borderSubtle),
          ),

          Text(
            'To fund this for 25 years you need:',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          RupeeDisplay(
            amount: requiredCorpus,
            size: RupeeDisplaySize.large,
            color: AppColors.accentAmber,
          ),
          const SizedBox(height: 12),

          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current corpus',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% there',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundTertiary,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: constraints.maxWidth * progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, child) {
                    return Container(
                      width: val < 6 && progress > 0 ? 6 : val,
                      decoration: BoxDecoration(
                        color: AppColors.accentAmber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCTA(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigating back and optionally passing a global flag via provider to open power slider
        context.go('/dashboard');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.accentAmber.withValues(alpha: 0.1),
              AppColors.accentAmber.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.accentAmber.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Not on track yet?', style: AppTypography.headingSmall),
                const SizedBox(height: 2),
                Text(
                  'See how to close the gap',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.accentAmber,
            ),
          ],
        ),
      ),
    );
  }

  List<LifestyleGoal> _getMockDefaultsForTier(String tier) {
    // A simple fallback to generate freeezed items mimicking tier switch resets.
    // In a production app, we would import exactly the same constants the Onboarding used.
    if (tier == 'lavish') {
      return [
        const LifestyleGoal(
          id: 'home',
          category: 'home',
          emoji: '🏡',
          label: 'Home Utilities',
          monthlyAmountToday: 40000,
          inflationRate: 0.06,
        ),
        const LifestyleGoal(
          id: 'food',
          category: 'food',
          emoji: '🥗',
          label: 'Groceries',
          monthlyAmountToday: 30000,
          inflationRate: 0.06,
        ),
        const LifestyleGoal(
          id: 'travel',
          category: 'travel',
          emoji: '✈️',
          label: 'Travel',
          monthlyAmountToday: 50000,
          inflationRate: 0.06,
        ),
      ];
    }
    return [
      const LifestyleGoal(
        id: 'home',
        category: 'home',
        emoji: '🏡',
        label: 'Home Utilities',
        monthlyAmountToday: 15000,
        inflationRate: 0.06,
      ),
      const LifestyleGoal(
        id: 'food',
        category: 'food',
        emoji: '🥗',
        label: 'Groceries',
        monthlyAmountToday: 15000,
        inflationRate: 0.06,
      ),
    ];
  }
}
