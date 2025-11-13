import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/design_system/tokens/spacing_tokens.dart';

/// Keyboard and pointer friendly profile summary tile.
class ProfileSummaryTile extends StatefulWidget {
  const ProfileSummaryTile({
    super.key,
    required this.summary,
    required this.isBusy,
    required this.onActivate,
    required this.onRename,
    required this.onDelete,
    this.autofocus = false,
  });

  final ProfileSummary summary;
  final bool isBusy;
  final VoidCallback onActivate;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final bool autofocus;

  @override
  State<ProfileSummaryTile> createState() => _ProfileSummaryTileState();
}

class _ProfileSummaryTileState extends State<ProfileSummaryTile> {
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = widget.summary;
    final subtitle = profileSubtitle(summary);
    final canInteract = !widget.isBusy;
    final selectionColor = summary.isActive
        ? Colors.deepPurple.withOpacity(0.3)
        : Colors.black.withOpacity(0.12);
    final highlightBorder = Border.all(
      color: _focused ? theme.colorScheme.secondaryContainer : Colors.transparent,
      width: 2,
    );

    return FocusableActionDetector(
      autofocus: widget.autofocus,
      enabled: canInteract,
      onShowFocusHighlight: (value) => setState(() => _focused = value),
      onShowHoverHighlight: (value) => setState(() => _hovered = value),
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
        const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
        const SingleActivator(LogicalKeyboardKey.delete): const _DeleteIntent(),
        const SingleActivator(LogicalKeyboardKey.f2): const _RenameIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => _handleActivate(),
        ),
        _DeleteIntent: CallbackAction<_DeleteIntent>(
          onInvoke: (_) => _handleDelete(),
        ),
        _RenameIntent: CallbackAction<_RenameIntent>(
          onInvoke: (_) => _handleRename(),
        ),
      },
      child: Semantics(
        button: true,
        enabled: canInteract,
        selected: summary.isActive,
        label: '${summary.displayName}, $subtitle',
        hint: summary.isActive
            ? 'Active profile. Press Enter to continue.'
            : 'Press Enter to switch to this profile.',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: highlightBorder,
            color: _hovered && canInteract
                ? selectionColor.withOpacity(0.8)
                : selectionColor,
          ),
          child: InkWell(
            onTap: canInteract ? _handleActivate : null,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      summary.displayName.characters.first.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (summary.isActive)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.greenAccent.shade400,
                      ),
                    ),
                  PopupMenuButton<_ProfileTileAction>(
                    key: ValueKey('profile-actions-${summary.id}'),
                    enabled: canInteract,
                    onSelected: (action) {
                      switch (action) {
                        case _ProfileTileAction.rename:
                          _handleRename();
                        case _ProfileTileAction.delete:
                          _handleDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        key: const ValueKey('profile-actions.rename'),
                        value: _ProfileTileAction.rename,
                        child: const ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Rename'),
                        ),
                      ),
                      PopupMenuItem(
                        key: const ValueKey('profile-actions.delete'),
                        value: _ProfileTileAction.delete,
                        child: const ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleActivate() {
    if (!widget.isBusy) {
      widget.onActivate();
    }
  }

  void _handleRename() {
    if (!widget.isBusy) {
      widget.onRename();
    }
  }

  void _handleDelete() {
    if (!widget.isBusy) {
      widget.onDelete();
    }
  }
}

class _DeleteIntent extends Intent {
  const _DeleteIntent();
}

class _RenameIntent extends Intent {
  const _RenameIntent();
}

enum _ProfileTileAction { rename, delete }

String profileSubtitle(ProfileSummary summary) {
  final level = summary.level?.toUpperCase() ?? 'A1';
  final runs = summary.totalRuns;
  if (runs == 0) {
    return 'Fresh start · Level $level';
  }
  return '$level · $runs run${runs == 1 ? '' : 's'}';
}
