import 'package:flutter_riverpod/flutter_riverpod.dart';

class PowerupDefinition {
  const PowerupDefinition({
    required this.id,
    required this.name,
    required this.effect,
    required this.usage,
    required this.limits,
    this.available = false,
  });

  final String id;
  final String name;
  final String effect;
  final String usage;
  final String limits;
  final bool available;
}

const List<PowerupDefinition> _catalog = <PowerupDefinition>[
  PowerupDefinition(
    id: 'timeExtend',
    name: 'Time Extend',
    effect: 'Adds 60 seconds to the timer mid-run.',
    usage: 'Trigger on timeout to keep the run alive.',
    limits: 'Max 2 uses per run.',
    available: true,
  ),
  PowerupDefinition(
    id: 'rowBlaster',
    name: 'Row Blaster',
    effect: 'Collapses the board to four rows for this run.',
    usage: 'Toggle on the pre-run screen when you have a charge.',
    limits: 'One run per charge.',
    available: true,
  ),
  PowerupDefinition(
    id: 'hintGlow',
    name: 'Hint Glow',
    effect: 'Flashes the correct match for a random English word.',
    usage: 'Tap during a run to reveal a hint after cooldown.',
    limits: '1–2 uses per run · 20–30 second cooldown. Coming soon.',
  ),
  PowerupDefinition(
    id: 'freezeTimer',
    name: 'Freeze Timer',
    effect: 'Pauses the countdown for ~10 seconds while you keep playing.',
    usage: 'Tap anytime to freeze time.',
    limits: 'Single use per run. Coming soon.',
  ),
  PowerupDefinition(
    id: 'autoMatch',
    name: 'Auto-Match',
    effect: 'Instantly solves one random available pair.',
    usage: 'Tap when stuck to auto-resolve a match (no XP granted).',
    limits: 'Single use per run. Coming soon.',
  ),
  PowerupDefinition(
    id: 'audioEcho',
    name: 'Audio Echo',
    effect: 'Replays a Spanish tile audio and highlights its match.',
    usage: 'Tap to hear and highlight a pair for a short time.',
    limits: 'Up to 2 uses per run · 1–3 second highlight. Coming soon.',
  ),
];

final powerupDefinitionsProvider = Provider<List<PowerupDefinition>>((_) {
  return _catalog;
});
