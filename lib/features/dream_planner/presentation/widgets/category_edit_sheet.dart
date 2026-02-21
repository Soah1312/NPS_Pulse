import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/nps_card.dart';
import '../../../../shared/widgets/nps_button.dart';
import '../../../../shared/widgets/nps_text_field.dart';
import '../../../../shared/widgets/rupee_display.dart';
import '../providers/dream_planner_provider.dart';

class CategoryEditSheet extends ConsumerStatefulWidget {
  final String categoryId;
  final String emoji;
  final String label;
  final double currentAmount;
  final double inflationRate;
  final double inflationMultiplier;

  const CategoryEditSheet({
    super.key,
    required this.categoryId,
    required this.emoji,
    required this.label,
    required this.currentAmount,
    required this.inflationRate,
    required this.inflationMultiplier,
  });

  @override
  ConsumerState<CategoryEditSheet> createState() => _CategoryEditSheetState();
}

class _CategoryEditSheetState extends ConsumerState<CategoryEditSheet> {
  late TextEditingController _amountController;
  late double _amount;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.currentAmount.toInt().toString(),
    );
    _amount = widget.currentAmount;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
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

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  children: [
                    Text(
                      '${widget.emoji} ${widget.label}',
                      style: AppTypography.headingMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Monthly amount today',
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    NPSTextField(
                      controller: _amountController,
                      label: 'Current monthly spend',
                      hint: 'e.g. 15000',
                      prefixText: '₹ ',
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setState(() {
                          _amount = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    NPSCard(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'At retirement this becomes:',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TweenAnimationBuilder<double>(
                                  tween: Tween(
                                    begin: 0,
                                    end: _amount * widget.inflationMultiplier,
                                  ),
                                  duration: const Duration(milliseconds: 200),
                                  builder: (context, val, child) {
                                    return RupeeDisplay(
                                      amount: val,
                                      size: RupeeDisplaySize.medium,
                                      color: AppColors.accentBlue,
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    '/month',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      '${widget.label} costs typically grow at ${(widget.inflationRate * 100).toInt()}%/year',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textDisabled,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    NPSButton(
                      label: 'Update ${widget.label}',
                      onPressed: () async {
                        if (_amount <= 0) return;

                        // Update Provider which saves everything
                        await ref
                            .read(dreamPlannerProvider.notifier)
                            .updateLineItem(widget.categoryId, _amount);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${widget.label} updated ✓'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    NPSButton(
                      label: 'Cancel',
                      variant: NPSButtonVariant.ghost,
                      onPressed: () => Navigator.pop(context),
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
