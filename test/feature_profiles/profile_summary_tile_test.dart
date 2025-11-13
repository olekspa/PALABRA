import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:palabra/data_core/models/profile_summary.dart';
import 'package:palabra/feature_profiles/widgets/profile_summary_tile.dart';

void main() {
  group('ProfileSummaryTile keyboard flows', () {
    testWidgets('Enter activates the profile', (tester) async {
      var activated = false;
      final profile = _sampleProfile('Lucia', isActive: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSummaryTile(
              summary: profile,
              isBusy: false,
              autofocus: true,
              onActivate: () => activated = true,
              onRename: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(activated, isTrue);
    });

    testWidgets('Delete key routes to delete handler', (tester) async {
      var deleteTriggered = false;
      final profile = _sampleProfile('Mateo', isActive: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileSummaryTile(
              summary: profile,
              isBusy: false,
              autofocus: true,
              onActivate: () {},
              onRename: () {},
              onDelete: () => deleteTriggered = true,
            ),
          ),
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      expect(deleteTriggered, isTrue);
    });
  });
}

ProfileSummary _sampleProfile(
  String name, {
  bool isActive = false,
  int runs = 3,
}) {
  final now = DateTime(2024, 1, 1);
  return ProfileSummary(
    id: 'profile-$name',
    displayName: name,
    createdAt: now,
    lastSeenAt: now,
    level: 'b1',
    totalRuns: runs,
    isActive: isActive,
  );
}
