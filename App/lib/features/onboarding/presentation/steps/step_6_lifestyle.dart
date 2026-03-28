import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/nps_button.dart';
import '../../../../shared/widgets/nps_card.dart';
import '../../../../shared/widgets/nps_text_field.dart';
import '../../../../shared/widgets/rupee_display.dart';
import '../../domain/onboarding_state.dart';
import '../onboarding_provider.dart';

// ────────────────────────────────────────────────────────────
// Tier definitions
// ────────────────────────────────────────────────────────────

class _TierDef {
  final String key;
  final String name;
  final String tagline;
  final double monthlyTotal;
  final Color accentColor;
  final List<LifestyleLineItem> lineItems;
  final bool showMostPopular;

  const _TierDef({
    required this.key,
    required this.name,
    required this.tagline,
    required this.monthlyTotal,
    required this.accentColor,
    required this.lineItems,
    this.showMostPopular = false,
  });
}

final _tiers = [
  _TierDef(
    key: 'essential',
    name: 'Essential',
    tagline: 'Comfortable and secure',
    monthlyTotal: 60000,
    accentColor: AppColors.accentBlue,
    lineItems: const [
      LifestyleLineItem(
        emoji: '🏠',
        label: 'Home expenses',
        monthlyAmount: 20000,
      ),
      LifestyleLineItem(
        emoji: '🏥',
        label: 'Basic healthcare',
        monthlyAmount: 10000,
      ),
      LifestyleLineItem(
        emoji: '🍽️',
        label: 'Regular dining',
        monthlyAmount: 15000,
      ),
      LifestyleLineItem(
        emoji: '✈️',
        label: 'Domestic travel',
        monthlyAmount: 15000,
        tripsPerYear: 1,
      ),
      LifestyleLineItem(
        emoji: '🌏',
        label: 'International travel',
        monthlyAmount: 0,
        tripsPerYear: 0,
      ),
    ],
  ),
  _TierDef(
    key: 'comfortable',
    name: 'Comfortable',
    tagline: 'The good life, well planned',
    monthlyTotal: 120000,
    accentColor: AppColors.accentAmber,
    showMostPopular: true,
    lineItems: const [
      LifestyleLineItem(
        emoji: '🏠',
        label: 'Home + maintenance',
        monthlyAmount: 35000,
      ),
      LifestyleLineItem(
        emoji: '🏥',
        label: 'Comprehensive healthcare',
        monthlyAmount: 20000,
      ),
      LifestyleLineItem(
        emoji: '🍽️',
        label: 'Dining + entertainment',
        monthlyAmount: 25000,
      ),
      LifestyleLineItem(
        emoji: '✈️',
        label: 'Domestic travel',
        monthlyAmount: 20000,
        tripsPerYear: 2,
      ),
      LifestyleLineItem(
        emoji: '🌏',
        label: 'International travel',
        monthlyAmount: 20000,
        tripsPerYear: 1,
      ),
    ],
  ),
  _TierDef(
    key: 'lavish',
    name: 'Lavish',
    tagline: 'No compromises',
    monthlyTotal: 250000,
    accentColor: const Color(0xFFAB47BC),
    lineItems: const [
      LifestyleLineItem(
        emoji: '🏠',
        label: 'Premium home',
        monthlyAmount: 70000,
      ),
      LifestyleLineItem(
        emoji: '🏥',
        label: 'Premium health + wellness',
        monthlyAmount: 40000,
      ),
      LifestyleLineItem(
        emoji: '🍽️',
        label: 'Fine dining + lifestyle',
        monthlyAmount: 60000,
      ),
      LifestyleLineItem(
        emoji: '✈️',
        label: 'Domestic travel',
        monthlyAmount: 40000,
        tripsPerYear: 4,
      ),
      LifestyleLineItem(
        emoji: '🌏',
        label: 'International travel',
        monthlyAmount: 40000,
        tripsPerYear: 2,
      ),
    ],
  ),
];

// ────────────────────────────────────────────────────────────
// Step 6: Lifestyle Tier Selector
// ────────────────────────────────────────────────────────────

class Step6Lifestyle extends ConsumerStatefulWidget {
  const Step6Lifestyle({super.key});

  @override
  ConsumerState<Step6Lifestyle> createState() => _Step6LifestyleState();
}

class _Step6LifestyleState extends ConsumerState<Step6Lifestyle> {
  // Track customized amounts per tier
  late Map<String, List<LifestyleLineItem>> _customizedItems;

  @override
  void initState() {
    super.initState();
    _customizedItems = {};
    for (final tier in _tiers) {
      _customizedItems[tier.key] = List.from(tier.lineItems);
    }

    // Initialize provider with default "comfortable" tier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(onboardingProvider);
      if (state.lifestyleLineItems.isEmpty) {
        final comfortableTier = _tiers.firstWhere(
          (t) => t.key == 'comfortable',
        );
        ref
            .read(onboardingProvider.notifier)
            .selectTier(
              'comfortable',
              comfortableTier.monthlyTotal,
              List.from(comfortableTier.lineItems),
            );
      }
    });
  }

  double _totalFor(String tierKey) {
    return _customizedItems[tierKey]!.fold(
      0.0,
      (sum, item) => sum + item.monthlyAmount,
    );
  }

  void _selectTier(String tierKey) {
    final items = _customizedItems[tierKey]!;
    final total = _totalFor(tierKey);
    ref.read(onboardingProvider.notifier).selectTier(tierKey, total, items);
  }

  void _openCustomize(BuildContext context, _TierDef tier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CustomizeSheet(
        tierName: tier.name,
        accentColor: tier.accentColor,
        items: List.from(_customizedItems[tier.key]!),
        onApply: (updatedItems) {
          setState(() {
            _customizedItems[tier.key] = updatedItems;
          });
          // Update provider if this tier is currently selected
          final selectedTier = ref.read(onboardingProvider).selectedTierName;
          if (selectedTier == tier.key) {
            final total = updatedItems.fold(
              0.0,
              (sum, item) => sum + item.monthlyAmount,
            );
            ref
                .read(onboardingProvider.notifier)
                .selectTier(tier.key, total, updatedItems);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final selectedTier = state.selectedTierName;
    final monthlyAmount = state.retirementMonthlyAmount;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                Text(
                  'What does your\nretirement look like?',
                  style: AppTypography.displaySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Choose a lifestyle tier as your starting point',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Tier cards
                for (final tier in _tiers) ...[
                  _TierCard(
                    tier: tier,
                    isSelected: selectedTier == tier.key,
                    currentTotal: _totalFor(tier.key),
                    onTap: () => _selectTier(tier.key),
                    onCustomize: () => _openCustomize(context, tier),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),

        // Summary bar fixed above Continue button
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: NPSCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Text(
                  'Your retirement will need approximately:',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                RupeeDisplay(
                  amount: monthlyAmount,
                  size: RupeeDisplaySize.large,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "That's ${CurrencyFormatter.formatCompact(monthlyAmount * 12 * 20)} corpus over 20 years",
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────
// Tier Card
// ────────────────────────────────────────────────────────────

class _TierCard extends StatelessWidget {
  final _TierDef tier;
  final bool isSelected;
  final double currentTotal;
  final VoidCallback onTap;
  final VoidCallback onCustomize;

  const _TierCard({
    required this.tier,
    required this.isSelected,
    required this.currentTotal,
    required this.onTap,
    required this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.backgroundTertiary
              : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isSelected ? tier.accentColor : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tier.name, style: AppTypography.headingMedium),
                        const SizedBox(height: 2),
                        Text(
                          tier.tagline,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.formatCompact(currentTotal),
                      style: AppTypography.amountMedium.copyWith(
                        color: tier.accentColor,
                      ),
                    ),
                  ],
                ),
                if (tier.showMostPopular)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentAmber,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.chipRadius,
                        ),
                      ),
                      child: Text(
                        'Most Popular',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.backgroundPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: AppSpacing.sm),

            // Line items
            for (final item in tier.lineItems)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(item.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(item.label, style: AppTypography.bodySmall),
                    ),
                    Text(
                      CurrencyFormatter.formatCompact(item.monthlyAmount),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.md),

            // Customize button
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onCustomize,
                child: Text(
                  'Customize →',
                  style: AppTypography.bodySmall.copyWith(
                    color: tier.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Customize Bottom Sheet
// ────────────────────────────────────────────────────────────

class _CustomizeSheet extends StatefulWidget {
  final String tierName;
  final Color accentColor;
  final List<LifestyleLineItem> items;
  final ValueChanged<List<LifestyleLineItem>> onApply;

  const _CustomizeSheet({
    required this.tierName,
    required this.accentColor,
    required this.items,
    required this.onApply,
  });

  @override
  State<_CustomizeSheet> createState() => _CustomizeSheetState();
}

class _CustomizeSheetState extends State<_CustomizeSheet> {
  late List<LifestyleLineItem> _editedItems;
  late List<TextEditingController> _amountControllers;
  late List<TextEditingController> _tripControllers;

  @override
  void initState() {
    super.initState();
    _editedItems = List.from(widget.items);
    _amountControllers = _editedItems
        .map(
          (item) => TextEditingController(
            text: item.monthlyAmount.round().toString(),
          ),
        )
        .toList();
    _tripControllers = _editedItems
        .map(
          (item) =>
              TextEditingController(text: item.tripsPerYear?.toString() ?? ''),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final c in _amountControllers) {
      c.dispose();
    }
    for (final c in _tripControllers) {
      c.dispose();
    }
    super.dispose();
  }

  double get _total =>
      _editedItems.fold(0.0, (sum, item) => sum + item.monthlyAmount);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Customize your ${widget.tierName} plan',
                    style: AppTypography.headingMedium,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Editable items
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  itemCount: _editedItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final item = _editedItems[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                item.label,
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: NPSTextField(
                                label: '₹/month',
                                prefixText: '₹ ',
                                controller: _amountControllers[index],
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  final parsed = double.tryParse(
                                    value.replaceAll(',', ''),
                                  );
                                  if (parsed != null) {
                                    setState(() {
                                      _editedItems[index] = item.copyWith(
                                        monthlyAmount: parsed,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        if (item.tripsPerYear != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 30,
                              top: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Trips/year:',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                SizedBox(
                                  width: 60,
                                  child: NPSTextField(
                                    label: '',
                                    controller: _tripControllers[index],
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      final parsed = int.tryParse(value);
                                      if (parsed != null) {
                                        setState(() {
                                          _editedItems[index] = item.copyWith(
                                            tripsPerYear: parsed,
                                          );
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),

              // Updated total + Apply button
              Container(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Updated monthly need: ${CurrencyFormatter.formatCompact(_total)}',
                      style: AppTypography.amountSmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    NPSButton(
                      label: 'Apply Changes',
                      onPressed: () {
                        widget.onApply(_editedItems);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
