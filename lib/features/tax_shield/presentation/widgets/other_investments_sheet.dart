import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/nps_button.dart';
import '../../../../shared/widgets/nps_text_field.dart';
import '../providers/tax_shield_provider.dart';

class OtherInvestmentsSheet extends ConsumerStatefulWidget {
  const OtherInvestmentsSheet({super.key});

  @override
  ConsumerState<OtherInvestmentsSheet> createState() =>
      _OtherInvestmentsSheetState();
}

class _OtherInvestmentsSheetState extends ConsumerState<OtherInvestmentsSheet> {
  final _ppfController = TextEditingController();
  final _elssController = TextEditingController();
  final _licController = TextEditingController();
  final _homeLoanController = TextEditingController();
  final _otherController = TextEditingController();

  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _ppfController.addListener(_calculateTotal);
    _elssController.addListener(_calculateTotal);
    _licController.addListener(_calculateTotal);
    _homeLoanController.addListener(_calculateTotal);
    _otherController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    _ppfController.dispose();
    _elssController.dispose();
    _licController.dispose();
    _homeLoanController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    double parse(String text) {
      final sanitized = text.replaceAll(',', '');
      return double.tryParse(sanitized) ?? 0.0;
    }

    setState(() {
      _totalAmount =
          parse(_ppfController.text) +
          parse(_elssController.text) +
          parse(_licController.text) +
          parse(_homeLoanController.text) +
          parse(_otherController.text);
    });
  }

  void _handleSave() {
    ref.read(taxShieldLocalProvider.notifier).updateOther80C(_totalAmount);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Grabber handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 24),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  children: [
                    Text(
                      'Your other 80C investments',
                      style: AppTypography.headingMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'These help us calculate how much of your ₹1.5L 80C limit is already used so we can accurately estimate your NPS tax benefits.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    NPSTextField(
                      label: 'PPF contribution',
                      hint: '0',
                      controller: _ppfController,
                      keyboardType: TextInputType.number,
                      prefixText: '₹ ',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    NPSTextField(
                      label: 'ELSS mutual funds',
                      hint: '0',
                      controller: _elssController,
                      keyboardType: TextInputType.number,
                      prefixText: '₹ ',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    NPSTextField(
                      label: 'Life insurance premium (LIC)',
                      hint: '0',
                      controller: _licController,
                      keyboardType: TextInputType.number,
                      prefixText: '₹ ',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    NPSTextField(
                      label: 'Home loan principal repayment',
                      hint: '0',
                      controller: _homeLoanController,
                      keyboardType: TextInputType.number,
                      prefixText: '₹ ',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    NPSTextField(
                      label: 'Other 80C investments',
                      hint: '0',
                      controller: _otherController,
                      keyboardType: TextInputType.number,
                      prefixText: '₹ ',
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
              // Sticky bottom bar
              Container(
                padding: EdgeInsets.only(
                  left: AppSpacing.screenPadding,
                  right: AppSpacing.screenPadding,
                  top: AppSpacing.md,
                  bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  border: Border(
                    top: BorderSide(color: AppColors.borderSubtle, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total 80C investments:',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '₹${_totalAmount.toStringAsFixed(0)}',
                          style: AppTypography.headingSmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    NPSButton(label: 'Save', onPressed: _handleSave),
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
