// Presentation-only widgets; dartdoc would mirror UI copy.
// ignore_for_file: public_member_api_docs

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palabra/app/router/app_router.dart';
import 'package:palabra/design_system/tokens/spacing_tokens.dart';
import 'package:palabra/design_system/widgets/gradient_background.dart';
import 'package:palabra/feature_games/application/game_registry.dart';
import 'package:palabra/feature_games/application/selected_game_provider.dart';
import 'package:palabra/feature_games/data/game_catalog.dart';

/// Hub screen that lists available and upcoming Palabra mini-games.
class GameHubScreen extends ConsumerWidget {
  const GameHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final registry = ref.watch(gameRegistryProvider);
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Palabra Arcade',
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Choose a mini-game to start practicing.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: ListView.separated(
                    itemCount: registry.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, index) {
                      final entry = registry[index];
                      final game = entry.descriptor;
                      VoidCallback? onPlay;
                      if (game.id == GameId.palabraLines) {
                        onPlay = () {
                          context.go(AppRoute.palabraLines.path);
                        };
                      } else if (game.id != null) {
                        onPlay = () {
                          ref.read(selectedGameProvider.notifier).state =
                              game.id!;
                          context.go(AppRoute.gate.path);
                        };
                      }
                      return _GameCard(
                        descriptor: game,
                        onPlay: onPlay,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatefulWidget {
  const _GameCard({
    required this.descriptor,
    required this.onPlay,
  });

  final GameDescriptor descriptor;
  final VoidCallback? onPlay;

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final descriptor = widget.descriptor;
    final canPlay = widget.onPlay != null && !descriptor.comingSoon;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _hovered ? 1.01 : 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: <Color>[
                    descriptor.color.withValues(alpha: 0.85),
                    descriptor.color.withValues(alpha: 0.65),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 24,
                    offset: Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    descriptor.icon,
                    size: 48,
                    color: descriptor.accent,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    descriptor.tagline.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: descriptor.accent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    descriptor.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    descriptor.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: canPlay ? widget.onPlay : null,
                        child: Text(descriptor.comingSoon ? 'Locked' : 'Play'),
                      ),
                      if (descriptor.comingSoon)
                        Padding(
                          padding: const EdgeInsets.only(left: AppSpacing.sm),
                          child: Text(
                            'Arriving soon',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
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
}
