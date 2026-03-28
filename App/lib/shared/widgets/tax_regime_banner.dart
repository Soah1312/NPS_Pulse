import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'nps_button.dart';

/// Dismissible banner prompting users who haven't set their tax regime.
/// Shows at the top of the dashboard when profile.tax_regime is empty.
class TaxRegimeBanner extends StatelessWidget {
  final VoidCallback? onDismiss;

  const TaxRegimeBanner({super.key, this.onDismiss});

  static Future<void> showTaxRegimeSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _TaxRegimeBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.accentAmber,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Unlock your Tax Shield — tell us your tax regime',
              style: AppTypography.bodyMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () => showTaxRegimeSheet(context),
            child: Text(
              'Set up →',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accentAmber,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Tax Regime Bottom Sheet (same content as old step 7)
// ────────────────────────────────────────────────────────────

class _TaxRegimeBottomSheet extends StatefulWidget {
  const _TaxRegimeBottomSheet();

  @override
  State<_TaxRegimeBottomSheet> createState() => _TaxRegimeBottomSheetState();
}

class _TaxRegimeBottomSheetState extends State<_TaxRegimeBottomSheet> {
  String? _selectedRegime;

  Future<void> _confirmSelection() async {
    if (_selectedRegime == null) return;

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id ?? '';

      await client
          .from('profiles')
          .update({'tax_regime': _selectedRegime})
          .eq('id', userId);

      if (mounted) {
        Navigator.of(context).pop(_selectedRegime);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Text('Choose your tax regime', style: AppTypography.headingMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'This helps us calculate your NPS tax benefits accurately',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            _RegimeCard(
              title: 'Old Regime',
              description:
                  'Higher deductions — ₹2L under 80C, HRA, LTA, and ₹50K extra for NPS under 80CCD(1B)',
              tags: const ['80C Deductions', '80CCD(1B) ₹50K'],
              isSelected: _selectedRegime == 'old',
              onTap: () => setState(() => _selectedRegime = 'old'),
            ),
            const SizedBox(height: AppSpacing.md),
            _RegimeCard(
              title: 'New Regime',
              description:
                  'Lower rates, fewer deductions — standard deduction of ₹75K, employer NPS up to 14%',
              tags: const ['Lower Rates', 'Simpler Filing'],
              isSelected: _selectedRegime == 'new',
              onTap: () => setState(() => _selectedRegime = 'new'),
            ),

            const SizedBox(height: AppSpacing.xl),
            NPSButton(
              label: 'Confirm Selection',
              onPressed: _selectedRegime != null ? _confirmSelection : () {},
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _RegimeCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> tags;
  final bool isSelected;
  final VoidCallback onTap;

  const _RegimeCard({
    required this.title,
    required this.description,
    required this.tags,
    required this.isSelected,
    required this.onTap,
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
            color: isSelected ? AppColors.accentAmber : AppColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: AppTypography.headingMedium),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.accentAmber,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPrimary,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.chipRadius,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.accentAmber,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
