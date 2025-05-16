import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';

void main() {
  late TestLayoutModel layoutModel;
  late TestLayout layout;

  setUp(
    () {
      layoutModel = TestLayoutModel();
      layout = TestLayout(
        TestLayoutModelFactory(
          layoutModel,
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
        AnimationController(vsync: layoutModel);
      } catch (e) {
        expectError = e;
      }
      expect(expectError, isNull);

      try {
        AnimationController(vsync: layoutModel);
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
            'If a LayoutModel is used for multiple AnimationController\n'
            'objects, or if it is passed to other objects and those objects\n'
            'might use it more than one time in total, then instead of mixing\n'
            'in a SingleTickerProviderLayout, use a regular\n'
            'TickerProviderLayout.\n'
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
      unawaited(layoutModel.controller.repeat());

      try {
        layoutModel.dispose();
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
          '   TestLayoutModel#00000(ticker active) was disposed with an active\n'
          '   Ticker.\n'
          '   TestLayoutModel created a Ticker via its\n'
          '   SingleTickerProviderLayout, but at the time dispose() was called\n'
          '   on the mixin, that Ticker was still active. The Ticker must be\n'
          '   disposed before calling super.dispose().\n'
          '   Tickers used by AnimationControllers should be disposed by\n'
          '   calling dispose() on the AnimationController itself. Otherwise,\n'
          '   the ticker will leak.\n'
          '   The offending ticker was:\n'
          '     Ticker(created by TestLayoutModel#00000)\n'
          '     The stack trace when the Ticker was actually created was:\n',
        ),
      );

      layoutModel.controller.stop();
      expectError = null;

      try {
        layoutModel.dispose();
      } catch (e) {
        expectError = e;
      }

      expect(expectError, isNull);
    },
  );
}

final class TestLayoutModelFactory implements LayoutModelFactory {
  final TestLayoutModel layoutModel;

  TestLayoutModelFactory(
    this.layoutModel,
  );

  @override
  TestLayoutModel call() => layoutModel;
}

class TestLayoutModel extends LayoutModel with SingleTickerProviderLayout {
  late AnimationController controller = AnimationController(
    duration: const Duration(seconds: 6),
    vsync: this,
  );
}

class TestLayout extends Layout {
  const TestLayout(
    super.layoutModelFactory, {
    super.key,
  });

  @override
  Widget build(TestLayoutModel layoutModel) {
    return MaterialApp(
      home: Scaffold(
        body: Placeholder(),
      ),
    );
  }
}
