import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';

void main() {
  late TestUILayoutController layoutController;
  late TestLayout layout;

  setUp(
    () {
      layoutController = TestUILayoutController();
      layout = TestLayout(
        TestLayoutControllerFactory(
          layoutController,
        ),
      );
    },
  );

  testWidgets(
    'When embedding a layout with two AnimationController in a tree,'
    ' there should be no errors',
    (tester) async {
      expect(
        () async => tester.pumpWidget(layout),
        returnsNormally,
      );
    },
  );

  testWidgets(
    'Calling dispose() method while the ticker is active should '
    'throw a specific error',
    (tester) async {
      await tester.pumpWidget(layout);
      unawaited(layoutController.controller.repeat());
      Object? expectError;

      try {
        layoutController.dispose();
      } catch (e) {
        expectError = e;
      }

      expect(expectError, isNotNull);
      expect(expectError, isFlutterError);

      final error = expectError as FlutterError;

      expect(error.diagnostics.length, 4);
      expect(error.diagnostics[2].level, DiagnosticLevel.hint);
      expect(
        error.diagnostics[2].toStringDeep(),
        'Tickers used by AnimationControllers should be disposed by\n'
        'calling dispose() on the AnimationController itself. Otherwise,\n'
        'the ticker will leak.\n',
      );
      expect(error.diagnostics[3], isA<DiagnosticsProperty<Ticker>>());
      expect(
        error.toStringDeep().split('\n').take(13).join('\n'),
        equalsIgnoringHashCodes(
          'FlutterError\n'
          '   TestUILayoutController#00000(tickers: tracking 1 ticker) was\n'
          '   disposed with an active Ticker.\n'
          '   TestUILayoutController created a Ticker via its\n'
          '   TickerProviderLayoutMixin, but at the time dispose() was called\n'
          '   on the mixin, that Ticker was still active. All Tickers must be\n'
          '   disposed before calling super.dispose().\n'
          '   Tickers used by AnimationControllers should be disposed by\n'
          '   calling dispose() on the AnimationController itself. Otherwise,\n'
          '   the ticker will leak.\n'
          '   The offending ticker was:\n'
          '     _WidgetTicker(created by TestUILayoutController#00000)\n'
          '     The stack trace when the _WidgetTicker was actually created\n',
        ),
      );

      layoutController.controller.stop();
      expectError = null;

      try {
        layoutController.dispose();
      } catch (e) {
        expectError = e;
      }

      expect(expectError, isNull);

      layoutController.controller.dispose();
    },
  );
}

final class TestLayoutControllerFactory implements LayoutControllerFactory {
  final TestUILayoutController layoutController;

  TestLayoutControllerFactory(this.layoutController);

  @override
  BaseLayoutController call() => layoutController;
}

final class TestUILayoutController extends UILayoutController
    with TickerProviderLayoutMixin {
  late AnimationController controller = AnimationController(
    duration: const Duration(seconds: 6),
    vsync: this,
  );

  late AnimationController controller2 = AnimationController(
    duration: const Duration(seconds: 6),
    vsync: this,
  );
}

class TestLayout extends Layout {
  const TestLayout(
    super.layoutControllerFactory, {
    super.key,
  });

  @override
  Widget build(TestUILayoutController layoutController) {
    return MaterialApp(
      home: Scaffold(
        body: Placeholder(),
      ),
    );
  }
}
