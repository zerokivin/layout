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
    'When embedding a layout in a tree, there should be no errors',
    (tester) async {
      expect(
        () async => tester.pumpWidget(layout),
        returnsNormally,
      );
    },
  );

  testWidgets(
    'There must be a definite error when trying to create two AnimationController',
    (tester) async {
      await tester.pumpWidget(layout);

      Object? expectError;
      try {
        AnimationController(vsync: layoutController);
      } catch (e) {
        expectError = e;
      }
      expect(expectError, isNull);

      try {
        AnimationController(vsync: layoutController);
      } catch (e) {
        expectError = e;
      }

      expect(expectError, isNotNull);
      expect(expectError, isFlutterError);
      final error = expectError as FlutterError;
      expect(error.diagnostics.length, 3);
      expect(error.diagnostics[2].level, DiagnosticLevel.hint);
      expect(
        error.diagnostics[2].toStringDeep(),
        equalsIgnoringHashCodes(
            'If a LayoutController is used for multiple AnimationController\n'
            'objects, or if it is passed to other objects and those objects\n'
            'might use it more than one time in total, then instead of mixing\n'
            'in a SingleTickerProviderLayoutMixin, use a regular\n'
            'TickerProviderLayoutMixin.\n'
            ''),
      );
    },
  );

  testWidgets(
    'Calling dispose() method while the ticker is active should '
    'throw a specific error',
    (tester) async {
      Object? expectError;
      await tester.pumpWidget(layout);
      unawaited(layoutController.controller.repeat());

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
          '   TestUILayoutController#00000(ticker active) was disposed with an\n'
          '   active Ticker.\n'
          '   TestUILayoutController created a Ticker via its\n'
          '   SingleTickerProviderLayoutMixin, but at the time dispose() was\n'
          '   called on the mixin, that Ticker was still active. The Ticker\n'
          '   must be disposed before calling super.dispose().\n'
          '   Tickers used by AnimationControllers should be disposed by\n'
          '   calling dispose() on the AnimationController itself. Otherwise,\n'
          '   the ticker will leak.\n'
          '   The offending ticker was:\n'
          '     Ticker(created by TestUILayoutController#00000)\n'
          '     The stack trace when the Ticker was actually created was:\n',
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
    with SingleTickerProviderLayoutMixin {
  late AnimationController controller = AnimationController(
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
