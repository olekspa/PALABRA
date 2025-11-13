import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/design_system/tokens/spacing_tokens.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_profiles/application/profile_controller.dart';
import 'package:palabra/feature_profiles/widgets/profile_summary_tile.dart';

/// Entry screen that lets learners choose, create, or manage profiles.
class ProfileSelectorScreen extends ConsumerStatefulWidget {
  /// Creates a new profile selector screen instance.
  const ProfileSelectorScreen({super.key});

  @override
  ConsumerState<ProfileSelectorScreen> createState() =>
      _ProfileSelectorScreenState();
}

class _ProfileSelectorScreenState extends ConsumerState<ProfileSelectorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(profileControllerProvider.notifier).refresh());
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncProfiles = ref.watch(profileControllerProvider);

    ref.listen<AsyncValue<List<ProfileSummary>>>(
      profileControllerProvider,
      (previous, next) {
        if (next.hasError && next.error != previous?.error) {
          _showError(next.error);
        }
      },
    );

    final profiles = asyncProfiles.valueOrNull;
    final isLoading = asyncProfiles.isLoading;
    final hasError = asyncProfiles.hasError;

    Widget content;
    if ((profiles == null || profiles.isEmpty) && isLoading) {
      content = const _LoadingView();
    } else if (hasError && profiles == null) {
      content = _ErrorView(
        onRetry: () => ref.read(profileControllerProvider.notifier).refresh(),
      );
    } else if (profiles == null || profiles.isEmpty) {
      content = _EmptyState(
        onCreate: isLoading ? null : () => _handleCreate(context),
      );
    } else {
      content = _ProfileListView(
        profiles: profiles,
        isBusy: isLoading,
        onCreate: () => _handleCreate(context),
        onSelect: (profile) => _handleSelect(context, profile),
        onRename: (profile) => _handleRename(context, profile),
        onDelete: (profile) => _handleDelete(context, profile),
      );
    }

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: content,
              ),
              if (isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreate(BuildContext context) async {
    final controller = ref.read(profileControllerProvider.notifier);
    final name = await _promptForName(
      context,
      title: 'Create profile',
      label: 'Profile name',
      confirmLabel: 'Create',
    );
    if (name == null) return;
    try {
      final summary = await controller.create(name);
      if (!context.mounted) return;
      _showSnack('Welcome, ${summary.displayName}!');
      context.go(AppRoute.gameHub.path);
    } on Object catch (error) {
      if (!context.mounted) return;
      _showError(error);
    }
  }

  Future<void> _handleSelect(
    BuildContext context,
    ProfileSummary profile,
  ) async {
    final controller = ref.read(profileControllerProvider.notifier);
    try {
      await controller.select(profile.id);
      if (!context.mounted) return;
      context.go(AppRoute.gameHub.path);
    } on Object catch (error) {
      if (!context.mounted) return;
      _showError(error);
    }
  }

  Future<void> _handleRename(
    BuildContext context,
    ProfileSummary profile,
  ) async {
    final controller = ref.read(profileControllerProvider.notifier);
    final name = await _promptForName(
      context,
      title: 'Rename profile',
      label: 'Profile name',
      confirmLabel: 'Save',
      initialValue: profile.displayName,
    );
    if (name == null || name == profile.displayName) return;
    try {
      await controller.rename(id: profile.id, name: name);
      if (!context.mounted) return;
      _showSnack('Renamed to $name');
    } on Object catch (error) {
      if (!context.mounted) return;
      _showError(error);
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    ProfileSummary profile,
  ) async {
    if (!await _confirmDelete(context, profile)) {
      return;
    }
    final controller = ref.read(profileControllerProvider.notifier);
    try {
      await controller.delete(profile.id);
      if (!context.mounted) return;
      _showSnack('Deleted ${profile.displayName}');
    } on Object catch (error) {
      if (!context.mounted) return;
      _showError(error);
    }
  }

  Future<String?> _promptForName(
    BuildContext context, {
    required String title,
    required String label,
    required String confirmLabel,
    String? initialValue,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return _ProfileNameDialog(
          title: title,
          label: label,
          confirmLabel: confirmLabel,
          initialValue: initialValue,
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context, ProfileSummary profile) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteProfileDialog(profile: profile),
    ).then((value) => value ?? false);
  }

  void _showError(Object? error) {
    if (!mounted || error == null) {
      return;
    }
    final message = error.toString();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _ProfileListView extends StatelessWidget {
  const _ProfileListView({
    required this.profiles,
    required this.isBusy,
    required this.onCreate,
    required this.onSelect,
    required this.onRename,
    required this.onDelete,
  });

  final List<ProfileSummary> profiles;
  final bool isBusy;
  final VoidCallback onCreate;
  final ValueChanged<ProfileSummary> onSelect;
  final ValueChanged<ProfileSummary> onRename;
  final ValueChanged<ProfileSummary> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ProfileSummary? activeProfile;
    for (final profile in profiles) {
      if (profile.isActive) {
        activeProfile = profile;
        break;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Who's playing?",
            style: theme.textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Profiles track streaks, XP, and vocabulary progress separately.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (activeProfile != null)
            _ActiveProfileBanner(
              profile: activeProfile,
              onContinue: isBusy ? null : () => onSelect(activeProfile!),
            ),
          if (activeProfile != null) const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: Material(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: Scrollbar(
                  radius: const Radius.circular(18),
                  thumbVisibility: profiles.length > 6,
                  child: GlowingOverscrollIndicator(
                    color: Colors.white.withValues(alpha: 0.15),
                    axisDirection: AxisDirection.down,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: profiles.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final profile = profiles[index];
                        final shouldAutofocus = profile.isActive ||
                            (activeProfile == null && index == 0);
                        return ProfileSummaryTile(
                          key: ValueKey('profile-tile-${profile.id}'),
                          summary: profile,
                          isBusy: isBusy,
                          autofocus: shouldAutofocus,
                          onActivate: () => onSelect(profile),
                          onRename: () => onRename(profile),
                          onDelete: () => onDelete(profile),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: isBusy ? null : onCreate,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Create profile'),
          ),
        ],
      ),
    );
  }
}

class _ActiveProfileBanner extends StatelessWidget {
  const _ActiveProfileBanner({
    required this.profile,
    required this.onContinue,
  });

  final ProfileSummary profile;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withValues(alpha: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Continue as ${profile.displayName}',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            profileSubtitle(profile),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 8,
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
                    'Create your first profile',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Profiles keep XP, streaks, and vocabulary '
                    'history separate for each learner.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: onCreate,
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Create profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: AppSpacing.md),
          const Text('Something went wrong.'),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

class _ProfileNameDialog extends StatefulWidget {
  const _ProfileNameDialog({
    required this.title,
    required this.label,
    required this.confirmLabel,
    this.initialValue,
  });

  final String title;
  final String label;
  final String confirmLabel;
  final String? initialValue;

  @override
  State<_ProfileNameDialog> createState() => _ProfileNameDialogState();
}

class _ProfileNameDialogState extends State<_ProfileNameDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: _errorText,
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        onChanged: (_) {
          if (_errorText != null) {
            setState(() => _errorText = null);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() => _errorText = 'Enter a name');
      return;
    }
    Navigator.of(context).pop(trimmed);
  }
}

/// Confirmation modal that safeguards profile deletion.
class DeleteProfileDialog extends StatefulWidget {
  /// Creates a delete confirmation dialog for [profile].
  const DeleteProfileDialog({required this.profile, super.key});

  /// Profile slated for deletion.
  final ProfileSummary profile;

  @override
  State<DeleteProfileDialog> createState() => _DeleteProfileDialogState();
}

/// Dialog state tracking confirmation input/acknowledgement.
class _DeleteProfileDialogState extends State<DeleteProfileDialog> {
  late final TextEditingController _controller;
  bool _acknowledged = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final subtitle = profileSubtitle(profile);
    final theme = Theme.of(context);
    final typedName = _controller.text.trim().toLowerCase();
    final nameMatch = typedName == profile.displayName.toLowerCase();
    final canDelete = nameMatch && _acknowledged;

    return AlertDialog(
      title: const Text('Delete profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'This removes "${profile.displayName}". Progress stays on this '
              'device, but the profile can’t be recovered.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withValues(alpha: 0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Type the profile name to confirm',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _acknowledged,
              onChanged: (value) {
                setState(() => _acknowledged = value ?? false);
              },
              title: const Text('I understand this can’t be undone'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: canDelete ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
