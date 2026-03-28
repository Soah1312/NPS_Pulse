import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/nps_card.dart';
import '../../../shared/widgets/tax_regime_banner.dart';
import '../../../features/onboarding/presentation/onboarding_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/readiness_arc_hero.dart';
import 'widgets/quick_stats_row.dart';
import 'widgets/dream_summary_card.dart';
import 'widgets/ai_assistant_sheet.dart';
import 'widgets/biggest_lever_card.dart';
import 'widgets/what_if_simulator.dart';

/// The fully-built NPS Pulse Dashboard screen.
/// Replaces the placeholder dashboard_home_screen.dart entirely.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _showBanner = true;
  late AnimationController _fabController;
  late Animation<double> _fabScale;

  // Progress bar animation triggers
  bool _snapshotVisible = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabScale = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    // Delay FAB appearance
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _fabController.forward();
    });

    // Trigger snapshot animations shortly after
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _snapshotVisible = true);
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openAIAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AIAssistantSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final dashboard = ref.watch(dashboardProvider);
    final authProfile = ref.watch(authProvider).value;

    final nameParts = (authProfile?.name ?? onboarding.firstName).split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts[0] : 'there';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final age = authProfile?.age ?? onboarding.age ?? 0;
    final retirementAge =
        authProfile?.targetRetirementAge ?? onboarding.targetRetirementAge;
    final monthlySalary =
        authProfile?.monthlySalary ?? onboarding.monthlySalary ?? 0.0;

    final currentCorpus = onboarding.currentCorpus ?? 0.0;
    final employeeContrib = onboarding.monthlyEmployeeContribution ?? 0.0;
    final employerContrib = onboarding.monthlyEmployerContribution ?? 0.0;
    final totalMonthlyContrib = employeeContrib + employerContrib;

    // Avatar initials
    final initials = [
      firstName.isNotEmpty ? firstName[0] : '',
      lastName.isNotEmpty ? lastName[0] : '',
    ].join().toUpperCase();

    final topPad = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // ── Main scrollable content
          SingleChildScrollView(
            padding: EdgeInsets.only(top: topPad, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── SECTION 1: Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()}, $firstName',
                              style: AppTypography.headingMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              age > 0
                                  ? 'Age $age · Retiring at $retirementAge'
                                  : 'Complete your profile',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Logout on avatar tap
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.backgroundTertiary,
                          child: Text(
                            initials.isNotEmpty ? initials : '?',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.accentAmber,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── SECTION 2: Tax Shield Banner
                if (_showBanner) ...[
                  TaxRegimeBanner(
                    onDismiss: () => setState(() => _showBanner = false),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── SECTION 3: Readiness Arc Hero
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: const ReadinessArcHero(),
                ),
                const SizedBox(height: 16),

                // Biggest Lever
                const BiggestLeverCard(),
                const SizedBox(height: 16),

                // ── SECTION 4: Quick Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: const QuickStatsRow(),
                ),
                const SizedBox(height: 16),

                // ── SECTION 5: Dream Summary Card
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: const DreamSummaryCard(),
                ),
                const SizedBox(height: 16),

                // ── SECTION 6: Retirement Snapshot
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: _RetirementSnapshot(
                    currentCorpus: currentCorpus,
                    requiredCorpus: dashboard.requiredCorpus,
                    totalMonthlyContrib: totalMonthlyContrib,
                    monthlySalary: monthlySalary,
                    yearsToRetirement: dashboard.yearsToRetirement,
                    visible: _snapshotVisible,
                  ),
                ),

                const SizedBox(height: 24),

                // ── SECTION 7: What If Simulator
                const WhatIfSimulator(),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // ── FAB: Floating AI Assistant button
          Positioned(
            right: AppSpacing.screenPadding,
            bottom: 24,
            child: ScaleTransition(
              scale: _fabScale,
              child: GestureDetector(
                onTap: _openAIAssistant,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentAmberLight,
                        AppColors.accentAmber,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentAmber.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Retirement Snapshot Section
// ─────────────────────────────────────────────────────────────

class _RetirementSnapshot extends StatelessWidget {
  final double currentCorpus;
  final double requiredCorpus;
  final double totalMonthlyContrib;
  final double monthlySalary;
  final int yearsToRetirement;
  final bool visible;

  const _RetirementSnapshot({
    required this.currentCorpus,
    required this.requiredCorpus,
    required this.totalMonthlyContrib,
    required this.monthlySalary,
    required this.yearsToRetirement,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    final corpusProgress = requiredCorpus > 0
        ? (currentCorpus / requiredCorpus * 100).clamp(0.0, 100.0)
        : 0.0;
    final contribRate = monthlySalary > 0
        ? (totalMonthlyContrib / monthlySalary * 100).clamp(0.0, 100.0)
        : 0.0;
    final timeEfficiency = (yearsToRetirement / 35 * 100).clamp(0.0, 100.0);

    return NPSCard(
      backgroundColor: AppColors.backgroundTertiary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where you stand today', style: AppTypography.headingSmall),
          const SizedBox(height: 12),
          _ProgressRow(
            label: 'Corpus vs Target',
            percentage: corpusProgress,
            visible: visible,
            delay: 0,
          ),
          const SizedBox(height: 8),
          _ProgressRow(
            label: 'Contribution Rate',
            percentage: contribRate,
            visible: visible,
            delay: 200,
          ),
          const SizedBox(height: 8),
          _ProgressRow(
            label: 'Time to grow',
            percentage: timeEfficiency,
            visible: visible,
            delay: 400,
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double percentage;
  final bool visible;
  final int delay;

  const _ProgressRow({
    required this.label,
    required this.percentage,
    required this.visible,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodySmall),
            Text(
              percentage > 0 && percentage < 1
                  ? '< 1%'
                  : '${percentage.toStringAsFixed(1)}%',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.accentAmber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
            color: AppColors.borderSubtle,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 800 + delay),
                  curve: Curves.easeOutCubic,
                  width: visible
                      ? (percentage > 0 && percentage < 1)
                            ? math.max(
                                6.0,
                                constraints.maxWidth * (percentage / 100),
                              )
                            : math.max(
                                percentage == 0 ? 0.0 : 6.0,
                                constraints.maxWidth * (percentage / 100),
                              )
                      : 0,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.gradientAmberStart,
                        AppColors.gradientAmberEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
