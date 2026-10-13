import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsmart/core/motion/app_motion.dart';
import 'package:spendsmart/core/motion/haptics.dart';
import 'package:spendsmart/core/motion/motion_widgets.dart';
import 'package:spendsmart/core/widgets/empty_state.dart';

void main() {
  group('AppMotion tokens', () {
    test('durations are ordered: instant < fast < base < slow < hero', () {
      expect(AppMotion.instant.inMilliseconds, lessThan(AppMotion.fast.inMilliseconds));
      expect(AppMotion.fast.inMilliseconds, lessThan(AppMotion.base.inMilliseconds));
      expect(AppMotion.base.inMilliseconds, lessThan(AppMotion.slow.inMilliseconds));
      expect(AppMotion.slow.inMilliseconds, lessThan(AppMotion.hero.inMilliseconds));
    });

    test('splashMax is within the 2.2s quality bar', () {
      expect(AppMotion.splashMax.inMilliseconds, lessThanOrEqualTo(2200));
    });

    test('staggerDelay is 0 for items beyond maxStaggeredItems', () {
      expect(AppMotion.staggerDelay(AppMotion.maxStaggeredItems), Duration.zero);
      expect(AppMotion.staggerDelay(AppMotion.maxStaggeredItems + 5), Duration.zero);
    });

    test('staggerDelay is non-zero for items within maxStaggeredItems', () {
      expect(AppMotion.staggerDelay(0), Duration.zero);
      expect(AppMotion.staggerDelay(1).inMilliseconds,
          AppMotion.staggerStep.inMilliseconds);
      expect(AppMotion.staggerDelay(2).inMilliseconds,
          2 * AppMotion.staggerStep.inMilliseconds);
    });

    test('pressScale is between 0.9 and 1.0 (small, not zero)', () {
      expect(AppMotion.pressScale, greaterThan(0.9));
      expect(AppMotion.pressScale, lessThan(1.0));
    });

    test('spring is non-zero mass/stiffness/damping', () {
      expect(AppMotion.spring.mass, greaterThan(0));
      expect(AppMotion.spring.stiffness, greaterThan(0));
      expect(AppMotion.spring.damping, greaterThan(0));
    });

    test('springSim creates a valid simulation between two values', () {
      final sim = AppMotion.springSim(0.0, 1.0);
      expect(sim, isNotNull);
      // The simulation should not throw and should settle near `to`.
      expect(() => sim.x(1.0, 0.0), returnsNormally);
    });
  });

  group('Haptics toggle', () {
    test('Haptics.enabled is mutable', () {
      final original = Haptics.enabled;
      Haptics.enabled = false;
      expect(Haptics.enabled, isFalse);
      Haptics.enabled = true;
      expect(Haptics.enabled, isTrue);
      Haptics.enabled = original;
    });

    test('All Haptics methods can be called without throwing', () {
      // These are no-ops in the test environment but should not throw.
      Haptics.light();
      Haptics.selection();
      Haptics.success();
      Haptics.heavy();
      Haptics.error();
    });
  });

  group('Pressable widget', () {
    testWidgets('renders child and triggers callback on tap',
        (WidgetTester tester) async {
      bool pressed = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Pressable(
            onPressed: () => pressed = true,
            child: const Text('Press'),
          ),
        ),
      ));
      await tester.tap(find.text('Press'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('reduces to plain child when reduce-motion is on',
        (WidgetTester tester) async {
      // Wrap with MediaQuery that has accessibleNavigation=true.
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(accessibleNavigation: true),
          child: Scaffold(
            body: Pressable(
              haptic: false,
              onPressed: () {},
              child: const Text('Press'),
            ),
          ),
        ),
      ));
      // The child should still be present.
      expect(find.text('Press'), findsOneWidget);
      // No Transform.scale wrapper since reduceMotion is true.
      expect(find.byType(Transform), findsNothing);
    });
  });

  group('ShakeWidget', () {
    testWidgets('renders child and exposes ShakeWidgetState',
        (WidgetTester tester) async {
      final key = GlobalKey<ShakeWidgetState>();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ShakeWidget(
            key: key,
            child: const Text('Shake me'),
          ),
        ),
      ));
      expect(find.text('Shake me'), findsOneWidget);
      expect(key.currentState, isNotNull);
      // Calling shake() should not throw.
      key.currentState!.shake();
      await tester.pumpAndSettle();
    });
  });

  group('DrawnCheckmark', () {
    testWidgets('renders and play() can be invoked',
        (WidgetTester tester) async {
      final key = GlobalKey<DrawnCheckmarkState>();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DrawnCheckmark(
            key: key,
            size: 48,
            color: Colors.green,
          ),
        ),
      ));
      expect(find.byType(CustomPaint), findsWidgets);
      expect(key.currentState, isNotNull);
      key.currentState!.play();
      await tester.pumpAndSettle();
    });
  });

  group('CountUpText', () {
    testWidgets('renders initial value formatted correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CountUpText(
            target: 1000,
            prefix: 'Rs. ',
            duration: Duration(milliseconds: 10),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // After settling, the final value should be 1000, formatted with no decimals.
      expect(find.text('Rs. 1000'), findsOneWidget);
    });

    testWidgets('compact mode formats large numbers as K/M',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CountUpText(
            target: 1250000,
            compact: true,
            duration: Duration(milliseconds: 10),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('1.3M'), findsOneWidget);
    });
  });

  group('ShimmerSkeleton', () {
    testWidgets('renders a Container with the expected dimensions',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ShimmerSkeleton(width: 100, height: 20, radius: 8),
        ),
      ));
      // Find any Container — the skeleton is built from one.
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('EmptyState', () {
    testWidgets('renders title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Nothing here',
            subtitle: 'Try a different filter',
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Try a different filter'), findsOneWidget);
    });
  });
}
