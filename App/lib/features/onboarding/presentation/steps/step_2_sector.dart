import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../onboarding_provider.dart';

class _SectorOption {
  final String key;
  final String emoji;
  final String label;
  final String description;

  const _SectorOption({
    required this.key,
    required this.emoji,
    required this.label,
    required this.description,
  });
}

const _sectors = [
  _SectorOption(
    key: 'central_govt',
    emoji: '🏛️',
    label: 'Central Govt',
    description: 'CPS / NPS Tier I mandatory',
  ),
  _SectorOption(
    key: 'state_govt',
    emoji: '🏢',
    label: 'State Govt',
    description: 'State-specific NPS rules',
  ),
  _SectorOption(
    key: 'private',
    emoji: '💼',
    label: 'Private',
    description: 'Voluntary + employer match',
  ),
  _SectorOption(
    key: 'self_employed',
    emoji: '🧑‍💻',
    label: 'Self-Employed',
    description: 'Voluntary, full control',
  ),
];

/// Step 2: Sector Selection — 2×2 grid of selectable cards
class Step2Sector extends ConsumerWidget {
  const Step2Sector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSector = ref.watch(onboardingProvider).sector;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Which sector do\nyou work in?',
            style: AppTypography.displaySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This determines your NPS rules and employer match',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.0,
              physics: const NeverScrollableScrollPhysics(),
              children: _sectors.map((sector) {
                final isSelected = selectedSector == sector.key;
                return _SectorCard(
                  sector: sector,
                  isSelected: isSelected,
                  onTap: () {
                    ref
                        .read(onboardingProvider.notifier)
                        .updateSector(sector.key);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectorCard extends StatefulWidget {
  final _SectorOption sector;
  final bool isSelected;
  final VoidCallback onTap;

  const _SectorCard({
    required this.sector,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SectorCard> createState() => _SectorCardState();
}

class _SectorCardState extends State<_SectorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.backgroundTertiary
                : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.accentAmber
                  : AppColors.borderSubtle,
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sector.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(widget.sector.label, style: AppTypography.headingSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.sector.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (widget.isSelected)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.accentAmber,
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
