import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/nps_card.dart';
import '../../../../shared/widgets/rupee_display.dart';

class DeductionSectionCard extends StatefulWidget {
  final String sectionName;
  final String plainEnglishTitle;
  final String plainEnglishDescription;
  final double maxAmount;
  final double utilizedAmount;
  final double missedAmount;
  final double taxSaved;
  final bool isAvailableInNewRegime;
  final bool isAvailableInSelectedRegime;
  final String currentRegimeName;

  const DeductionSectionCard({
    super.key,
    required this.sectionName,
    required this.plainEnglishTitle,
    required this.plainEnglishDescription,
    required this.maxAmount,
    required this.utilizedAmount,
    required this.missedAmount,
    required this.taxSaved,
    required this.isAvailableInNewRegime,
    required this.isAvailableInSelectedRegime,
    required this.currentRegimeName,
  });

  @override
  State<DeductionSectionCard> createState() => _DeductionSectionCardState();
}

class _DeductionSectionCardState extends State<DeductionSectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final ratio = widget.maxAmount > 0
        ? (widget.utilizedAmount / widget.maxAmount).clamp(0.0, 1.0)
        : 0.0;
    _progressAnim = Tween<double>(begin: 0, end: ratio).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant DeductionSectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.utilizedAmount != widget.utilizedAmount ||
        oldWidget.maxAmount != widget.maxAmount) {
      final ratio = widget.maxAmount > 0
          ? (widget.utilizedAmount / widget.maxAmount).clamp(0.0, 1.0)
          : 0.0;
      _progressAnim = Tween<double>(begin: _progressAnim.value, end: ratio)
          .animate(
            CurvedAnimation(
              parent: _animController,
              curve: Curves.easeOutCubic,
            ),
          );
      _animController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildAvailabilityChip() {
    if (widget.isAvailableInNewRegime) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.accentAmber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentAmber.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 12, color: AppColors.accentAmber),
            const SizedBox(width: 4),
            Text(
              'Both Regimes',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.accentAmber,
              ),
            ),
          ],
        ),
      );
    }

    if (!widget.isAvailableInSelectedRegime) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.close, size: 12, color: AppColors.danger),
            const SizedBox(width: 4),
            Text(
              'Not in New Regime',
              style: AppTypography.labelSmall.copyWith(color: AppColors.danger),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 12, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Old Regime',
            style: AppTypography.labelSmall.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double amount, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          RupeeDisplay(
            amount: amount,
            size: RupeeDisplaySize.small,
            color: amountColor,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If not matching constraints (e.g., SE with 80CCD2), handle opacity dimming logically
    final bool isApplicable = widget.maxAmount > 0;
    final bool isDimmed = !widget.isAvailableInSelectedRegime || !isApplicable;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Stack(
        children: [
          Opacity(
            opacity: isDimmed ? 0.6 : 1.0,
            child: NPSCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row (Badge + Availability)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundTertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.sectionName,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _buildAvailabilityChip(),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title and Description
                  if (!isApplicable) ...[
                    Text(
                      'Not applicable — no employer',
                      style: AppTypography.headingSmall,
                    ),
                  ] else ...[
                    Text(
                      widget.plainEnglishTitle,
                      style: AppTypography.headingSmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    widget.plainEnglishDescription,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.borderSubtle, height: 1),
                  const SizedBox(height: 12),

                  // 3 Stat Rows
                  _buildStatRow(
                    'Maximum allowed',
                    widget.maxAmount,
                    AppColors.textSecondary,
                  ),
                  _buildStatRow(
                    'You\'re claiming',
                    widget.utilizedAmount,
                    widget.utilizedAmount > 0
                        ? AppColors.success
                        : AppColors.textDisabled,
                  ),
                  _buildStatRow(
                    'You\'re missing',
                    widget.missedAmount,
                    widget.missedAmount == 0
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (context, child) {
                      Color fill = AppColors.danger;
                      if (widget.utilizedAmount >= widget.maxAmount &&
                          widget.maxAmount > 0) {
                        fill = AppColors.success;
                      } else if (widget.utilizedAmount > 0) {
                        fill = AppColors.warning;
                      }
                      if (!isApplicable) fill = AppColors.textDisabled;

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.borderSubtle,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              Container(
                                width:
                                    constraints.maxWidth * _progressAnim.value,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: fill,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Bottom Row Helper
                  if (widget.missedAmount > 0 &&
                      widget.isAvailableInSelectedRegime) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💡', style: AppTypography.bodySmall),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Saving ₹${widget.taxSaved.toStringAsFixed(0)} more is possible',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.accentAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (widget.missedAmount == 0 &&
                      widget.isAvailableInSelectedRegime &&
                      isApplicable) ...[
                    Row(
                      children: [
                        Text('✅', style: AppTypography.bodySmall),
                        const SizedBox(width: 6),
                        Text(
                          'Fully optimized',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Top non-dimmed banner
          if (!widget.isAvailableInSelectedRegime)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.cardRadius),
                    topRight: Radius.circular(AppSpacing.cardRadius),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Not available in ${widget.currentRegimeName == 'new' ? 'New' : 'Old'} Regime',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.backgroundPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
