import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/nps_card.dart';
import '../../../../shared/widgets/rupee_display.dart';

class LifestyleCategoryCard extends StatefulWidget {
  final String categoryId;
  final String emoji;
  final String label;
  final double amountToday;
  final double futureAmount;
  final double multiplier;
  final VoidCallback onEditTap;

  const LifestyleCategoryCard({
    super.key,
    required this.categoryId,
    required this.emoji,
    required this.label,
    required this.amountToday,
    required this.futureAmount,
    required this.multiplier,
    required this.onEditTap,
  });

  @override
  State<LifestyleCategoryCard> createState() => _LifestyleCategoryCardState();
}

class _LifestyleCategoryCardState extends State<LifestyleCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _widthAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _widthAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isVisible = true);
        _animController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant LifestyleCategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.multiplier != widget.multiplier) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: NPSCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(widget.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(widget.label, style: AppTypography.headingSmall),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onEditTap,
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Two column comparison
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT: Today
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        RupeeDisplay(
                          amount: widget.amountToday,
                          size: RupeeDisplaySize.small,
                          color: AppColors.accentAmber,
                        ),
                        Text(
                          '/month',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CENTER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.borderSubtle),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.accentBlue,
                      size: 20,
                    ),
                  ),

                  // RIGHT: Retirement
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'At retirement',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        RupeeDisplay(
                          amount: widget.futureAmount,
                          size: RupeeDisplaySize.small,
                          color: AppColors.accentBlue,
                        ),
                        Text(
                          '/month',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bottom Progress Visual
              Text(
                'Grows ${widget.multiplier.toStringAsFixed(1)}× due to inflation',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textDisabled,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  double baseRatio =
                      1.0 /
                      widget
                          .multiplier; // The proportion representing today's value vs future.

                  return Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundTertiary, // track
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      children: [
                        // Base amount slice
                        Container(
                          width: maxWidth * baseRatio,
                          decoration: const BoxDecoration(
                            color: AppColors.accentAmber,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(2),
                            ),
                          ),
                        ),
                        // Inflated growth slice
                        AnimatedBuilder(
                          animation: _widthAnimation,
                          builder: (context, child) {
                            final growthWidth =
                                maxWidth *
                                (1.0 - baseRatio) *
                                _widthAnimation.value;
                            return Container(
                              width: growthWidth,
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue,
                                borderRadius:
                                    growthWidth >=
                                        (maxWidth * (1.0 - baseRatio)) - 2
                                    ? const BorderRadius.horizontal(
                                        right: Radius.circular(2),
                                      )
                                    : BorderRadius.zero,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
