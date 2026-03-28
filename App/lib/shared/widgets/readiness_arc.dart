import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Circular arc gauge widget for displaying readiness score.
/// Placeholder — will be fully built when the readiness screen is implemented.
class ReadinessArc extends StatelessWidget {
  final double score; // 0.0 to 1.0
  final double size;
  final double strokeWidth;

  const ReadinessArc({
    super.key,
    required this.score,
    this.size = 200,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArcPainter(
          score: score.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Text(
            '${(score * 100).round()}',
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.accentAmber,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double score;
  final double strokeWidth;

  _ArcPainter({required this.score, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.backgroundTertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi * 0.75, math.pi * 1.5, false, bgPaint);

    // Score arc with gradient
    final scorePaint = Paint()
      ..shader = const SweepGradient(
        startAngle: math.pi * 0.75,
        endAngle: math.pi * 2.25,
        colors: [AppColors.gradientScoreStart, AppColors.gradientScoreEnd],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      math.pi * 0.75,
      math.pi * 1.5 * score,
      false,
      scorePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.strokeWidth != strokeWidth;
  }
}
