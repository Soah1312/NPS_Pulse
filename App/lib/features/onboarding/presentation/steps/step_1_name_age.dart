import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/nps_text_field.dart';
import '../onboarding_provider.dart';

/// Step 1: First Name, Last Name & Age
class Step1NameAge extends ConsumerStatefulWidget {
  const Step1NameAge({super.key});

  @override
  ConsumerState<Step1NameAge> createState() => _Step1NameAgeState();
}

class _Step1NameAgeState extends ConsumerState<Step1NameAge> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingProvider);
    _firstNameController = TextEditingController(text: state.firstName);
    _lastNameController = TextEditingController(text: state.lastName);
    _emailController = TextEditingController(text: state.email);
    _passwordController = TextEditingController(text: state.password);
    _ageController = TextEditingController(
      text: state.age != null ? state.age.toString() : '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Text('What should we\ncall you?', style: AppTypography.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "We'll personalize your retirement journey",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          NPSTextField(
            label: 'First name',
            hint: 'e.g. Arjun',
            controller: _firstNameController,
            keyboardType: TextInputType.name,
            onChanged: (value) {
              ref.read(onboardingProvider.notifier).updateFirstName(value);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          NPSTextField(
            label: 'Last name',
            hint: 'e.g. Sharma',
            controller: _lastNameController,
            keyboardType: TextInputType.name,
            onChanged: (value) {
              ref.read(onboardingProvider.notifier).updateLastName(value);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          NPSTextField(
            label: 'Email',
            hint: 'e.g. arjun@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              ref.read(onboardingProvider.notifier).updateEmail(value);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          NPSTextField(
            label: 'Password',
            hint: 'Minimum 6 characters',
            controller: _passwordController,
            obscureText: true,
            onChanged: (value) {
              ref.read(onboardingProvider.notifier).updatePassword(value);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          NPSTextField(
            label: 'Your age',
            hint: 'e.g. 28',
            controller: _ageController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              final age = int.tryParse(value);
              ref.read(onboardingProvider.notifier).updateAge(age);
            },
          ),
        ],
      ),
    );
  }
}
