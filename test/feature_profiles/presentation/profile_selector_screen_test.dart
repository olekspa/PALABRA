import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palabra/data_core/data_core.dart';
import 'package:palabra/feature_profiles/application/profile_repository.dart';
import 'package:palabra/feature_profiles/presentation/profile_selector_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> _resetStore() async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final store = InMemoryStore.instance;
    for (final id in List<String>.from(store.profileIds)) {
      store.deleteProfile(id);
    }
    final activeId = store.ensureActiveProfile();
    store.profileMeta(activeId).profileName = 'Player One';
    store.userMeta = UserMeta();
  }

  Future<void> _pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ProfileSelectorScreen()),
      ),
    );
    await tester.pump();
    for (var i = 0; i < 5; i += 1) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('shows active profile banner and list', (tester) async {
    await _resetStore();

    await _pumpScreen(tester);

    expect(find.textContaining('Continue as'), findsOneWidget);
    expect(find.text('Create profile'), findsOneWidget);
  });

  // Additional interaction tests live in integration coverage to avoid
  // juggling overlay timing in widget tests.
}
