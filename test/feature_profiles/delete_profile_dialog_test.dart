import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:palabra/data_core/models/profile_summary.dart';
import 'package:palabra/feature_profiles/presentation/profile_selector_screen.dart';

void main() {
  group('DeleteProfileDialog', () {
    testWidgets(
        'requires typing the profile name and acknowledging permanence '
        'before enabling delete', (tester) async {
      final profile = _sampleProfile();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeleteProfileDialog(profile: profile),
          ),
        ),
      );
      await tester.pumpAndSettle();

      FilledButton deleteButton() => tester.widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Delete'),
          );

      expect(deleteButton().onPressed, isNull);

      await tester.enterText(find.byType(TextField), profile.displayName);
      await tester.pumpAndSettle();
      expect(deleteButton().onPressed, isNull);

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      expect(deleteButton().onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), 'someone else');
      await tester.pumpAndSettle();
      expect(deleteButton().onPressed, isNull);
    });
  });
}

ProfileSummary _sampleProfile() {
  return ProfileSummary(
    id: 'profile-1',
    displayName: 'María',
    createdAt: DateTime(2024, 1, 1),
    lastSeenAt: DateTime(2024, 1, 2),
    level: 'b1',
    totalRuns: 7,
    isActive: true,
  );
}
