import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/design_system/tokens/spacing_tokens.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_gate/application/gate_access.dart';

/// Entry gate screen that verifies device and course availability.
class GateScreen extends ConsumerWidget {
  /// Creates a [GateScreen].
  const GateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(gateAccessProvider);
    final requiredCourseId = ref.watch(gateRequiredCourseProvider);
    final flags = ref.watch(gateFeatureFlagsProvider);

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
                          value: access.device.value,
                          isOk: access.device.allowed,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _GateStatusRow(
                          label: 'Course',
                          value: access.course.value,
                          isOk: access.course.allowed,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton(
                          onPressed: access.canProceed
                              ? () => context.go(AppRoute.preRun.path)
                              : null,
                          child: const Text('Continue'),
                        ),
                        if (_shouldShowOverrideNote(access, flags)) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Override flags granted access on this device. '
                            'Disable the PALABRA_* feature flags to restore '
                            'production gating.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ] else if (!access.canProceed) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Palabra is currently limited to '
                            '${_formatCourseName(requiredCourseId)} learners '
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

bool _shouldShowOverrideNote(
  GateAccessStatus status,
  GateFeatureFlags flags,
) {
  return status.device.overrideApplied ||
      (flags.forceCourseId != null && status.course.allowed);
}

String _formatCourseName(String value) {
  if (value.isEmpty) {
    return 'Spanish';
  }
  final segments = value.split(RegExp('[_\\-]')).where((s) => s.isNotEmpty);
  final formatted = segments
      .map(
        (segment) =>
            segment.substring(0, 1).toUpperCase() + segment.substring(1),
      )
      .join(' ');
  return formatted.isEmpty ? 'Spanish' : formatted;
}
