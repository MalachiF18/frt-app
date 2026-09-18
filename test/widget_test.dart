import 'package:button_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selects a weapon and supports hold-to-fire mode and range controls', (tester) async {
    await tester.pumpWidget(const GunRangeApp());

    expect(find.text('CHOOSE YOUR WEAPON'), findsOneWidget);
    expect(find.text('GLOCK 19X'), findsOneWidget);
    expect(find.text('GLOCK 17'), findsOneWidget);
    expect(find.text('AR PISTOL'), findsOneWidget);
    expect(find.text('DP-12 GEN 2'), findsOneWidget);

    // Select Glock 19X
    await tester.tap(find.byKey(const Key('select-glock19x')));
    await tester.pumpAndSettle();
    expect(find.text('AMMO  30 / 30'), findsOneWidget);

    // Verify Target Control elements exist
    expect(find.byKey(const Key('reset-target-button')), findsOneWidget);
    expect(find.byKey(const Key('target-type-dropdown')), findsOneWidget);
    expect(find.byKey(const Key('target-distance-segmented')), findsOneWidget);

    // Enable rapid fire mode
    await tester.tap(find.byKey(const Key('rapid-fire-switch')));
    await tester.pump();

    // Fire continuous burst
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('fire-control'))),
    );
    await tester.pump(const Duration(milliseconds: 360));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify ammo decreased
    final ammo = tester.widget<Text>(find.byKey(const Key('ammo-count'))).data!;
    expect(ammo, isNot('AMMO  30 / 30'));

    // Test Target Reset
    await tester.tap(find.byKey(const Key('reset-target-button')));
    await tester.pump();
    final score = tester.widget<Text>(find.byKey(const Key('score-count'))).data!;
    expect(score, contains('SCORE  0'));
  });
}
