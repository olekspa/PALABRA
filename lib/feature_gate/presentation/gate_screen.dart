import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/design_system/tokens/spacing_tokens.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';

/// Entry gate screen that verifies device and course availability.
class GateScreen extends ConsumerWidget {
  /// Creates a [GateScreen].
  const GateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Device gating is strict—mobile iOS is the launch target.
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    const isWeb = kIsWeb;
    final betaOverride = isWeb || kDebugMode;
    final isSupportedDevice = isIos;
    // TODO(content-team): Replace hard-coded course once LMS integration lands.
    const currentCourse = 'spanish';
    const requiredCourse = 'spanish';
    const isSupportedCourse = currentCourse == requiredCourse;
    final canProceed = (isSupportedDevice || betaOverride) && isSupportedCourse;
    final deviceStatus = isIos
        ? 'iPhone detected'
        : isWeb
            ? 'Web demo (beta)'
            : kDebugMode
                ? 'Debug override active'
                : 'Not supported';
    const courseStatus = isSupportedCourse
        ? 'Spanish course confirmed'
        : 'Requires Spanish course';

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Palabra',
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Make 90 correct matches in 1:45.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _GateStatusRow(
                          label: 'Device',
                          value: deviceStatus,
                          isOk: canProceed,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const _GateStatusRow(
                          label: 'Course',
                          value: courseStatus,
                          isOk: isSupportedCourse,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton(
                          onPressed: canProceed
                              ? () => context.go(AppRoute.preRun.path)
                              : null,
                          child: const Text('Continue'),
                        ),
                        if (!canProceed) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Palabra is currently limited to Spanish learners '
                            'on iPhone.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GateStatusRow extends StatelessWidget {
  const _GateStatusRow({
    required this.label,
    required this.value,
    required this.isOk,
  });

  final String label;
  final String value;
  final bool isOk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isOk ? Colors.white : Colors.redAccent;
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
