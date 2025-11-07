import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/feature_profiles/presentation/profile_selector_screen.dart';

void main() {
  setUp(() {
    final store = InMemoryStore.instance;
    for (final id in List<String>.from(store.profileIds)) {
      store.deleteProfile(id);
    }
    final metaA = UserMeta()
      ..profileName = 'Alex'
      ..createdAt = DateTime(2024, 1, 1)
      ..lastSeenAt = DateTime(2024, 1, 1);
    final metaB = UserMeta()
      ..profileName = 'Blair'
      ..createdAt = DateTime(2024, 1, 2)
      ..lastSeenAt = DateTime(2024, 1, 2);
    store.upsertProfile('alex', metaA);
    store.upsertProfile('blair', metaB);
    store.ensureActiveProfile(profileId: 'alex');
  });

  testWidgets('Profile selector exposes labeled controls', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfileSelectorScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final createButton = find.text('Create profile');
    expect(createButton, findsOneWidget);
    final createSemantics = tester.getSemantics(createButton);
    expect(createSemantics.hasFlag(SemanticsFlag.isButton), isTrue);

    final continueButton = find.text('Continue');
    if (continueButton.evaluate().isNotEmpty) {
      final continueSemantics = tester.getSemantics(continueButton);
      expect(continueSemantics.hasFlag(SemanticsFlag.isButton), isTrue);
    }

    semantics.dispose();
  });
}
