import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/onboarding_state.dart';

/// Row of 7 segments showing onboarding progress.
/// Completed = filled amber, Current = amber with pulse, Upcoming = subtle border color.
class OnboardingProgress extends StatelessWidget {
  final int currentStep;

  const OnboardingProgress({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: List.generate(OnboardingState.totalSteps * 2 - 1, (index) {
          if (index.isOdd) {
            return const SizedBox(width: 6);
          }
          final step = index ~/ 2 + 1;
          return Expanded(
            child: _Segment(step: step, currentStep: currentStep),
          );
        }),
      ),
    );
  }
}

class _Segment extends StatefulWidget {
  final int step;
  final int currentStep;

  const _Segment({required this.step, required this.currentStep});

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _Segment oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePulse();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePulse();
  }

  void _updatePulse() {
    if (widget.step == widget.currentStep) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.step < widget.currentStep;
    final isCurrent = widget.step == widget.currentStep;

    Color color;
    if (isCompleted || isCurrent) {
      color = AppColors.accentAmber;
    } else {
      color = AppColors.borderSubtle;
    }

    if (isCurrent) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            height: 3,
            decoration: BoxDecoration(
              color: color.withValues(alpha: _pulseAnimation.value),
              borderRadius: BorderRadius.circular(1.5),
            ),
          );
        },
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 3,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
