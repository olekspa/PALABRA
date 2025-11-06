import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/design_system/tokens/spacing_tokens.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_gate/application/gate_access.dart';
import 'package:palabra/feature_run/application/run_settings.dart';

/// Entry gate screen that verifies device and course availability.
class GateScreen extends ConsumerWidget {
  /// Creates a [GateScreen].
  const GateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessAsync = ref.watch(gateAccessProvider);
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
                    child: accessAsync.when(
                      data: (access) => _GateContent(
                        access: access,
                        flags: flags,
                        requiredCourseId: requiredCourseId,
                      ),
                      error: (error, stack) => _GateError(
                        message: 'Unable to evaluate device access.',
                      ),
                      loading: () => const _GateLoading(),
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

class _GateContent extends StatelessWidget {
  const _GateContent({
    required this.access,
    required this.flags,
    required this.requiredCourseId,
  });

  final GateAccessStatus access;
  final GateFeatureFlags flags;
  final String requiredCourseId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const runSettings = RunSettings();
    final runDuration = Duration(milliseconds: runSettings.runDurationMs);
    final minutes = runDuration.inMinutes;
    final seconds = (runDuration.inSeconds % 60).toString().padLeft(2, '0');
    final targetMatches = runSettings.minTargetMatches;
    final objectiveText =
        'Make $targetMatches correct matches in $minutes:$seconds.';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Palabra',
          style: textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          objectiveText,
          style: textTheme.bodyLarge,
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
              ? () => GoRouter.of(context).go(AppRoute.preRun.path)
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
            style: textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ] else if (!access.canProceed) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Palabra is currently limited to '
            '${_formatCourseName(requiredCourseId)} learners '
            'on supported devices.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ],
    );
  }
}

class _GateLoading extends StatelessWidget {
  const _GateLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 48,
        width: 48,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _GateError extends StatelessWidget {
  const _GateError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Palabra',
          style: textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Check your connection or restart the app.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: Colors.white70),
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
