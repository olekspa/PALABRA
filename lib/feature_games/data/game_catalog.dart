// Game metadata surfaced verbatim in the UI; extra dartdoc would duplicate the
// on-screen copy.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// Unique identifiers for Palabra mini-games.
enum GameId {
  wordMatch,
}

/// Immutable description for a game entry surfaced on the hub.
class GameDescriptor {
  const GameDescriptor({
    required this.title,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.color,
    required this.accent,
    this.id,
    this.comingSoon = false,
  });

  final GameId? id;
  final String title;
  final String tagline;
  final String description;
  final IconData icon;
  final Color color;
  final Color accent;
  final bool comingSoon;
}

/// Catalog of available + planned games.
const List<GameDescriptor> kGameCatalog = <GameDescriptor>[
  GameDescriptor(
    id: GameId.wordMatch,
    title: 'Palabra Word Match',
    tagline: 'Tap-to-match sprint',
    description:
        'Race the timer to pair English prompts with Spanish translations, '
        'earn streak XP, and unlock powerups.',
    icon: Icons.grid_view_rounded,
    color: Color(0xFF361E59),
    accent: Color(0xFF5CD1FF),
  ),
  GameDescriptor(
    title: 'Coming Soon',
    tagline: 'New drills on deck',
    description:
        'Additional listening, verb, and challenge modes are on the roadmap. '
        'Stay tuned!',
    icon: Icons.auto_awesome_rounded,
    color: Color(0xFF1F1F2E),
    accent: Color(0xFFE472B6),
    comingSoon: true,
  ),
];
