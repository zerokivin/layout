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
      unawaited(layoutModel.controller.repeat());
      Object? expectError;

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
          '   TestLayoutModel#00000(tickers: tracking 1 ticker) was disposed\n'
          '   with an active Ticker.\n'
          '   TestLayoutModel created a Ticker via its TickerProviderLayout,\n'
          '   but at the time dispose() was called on the mixin, that Ticker\n'
          '   was still active. All Tickers must be disposed before calling\n'
          '   super.dispose().\n'
          '   Tickers used by AnimationControllers should be disposed by\n'
          '   calling dispose() on the AnimationController itself. Otherwise,\n'
          '   the ticker will leak.\n'
          '   The offending ticker was:\n'
          '     _WidgetTicker(created by TestLayoutModel#00000)\n'
          '     The stack trace when the _WidgetTicker was actually created\n',
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

      layoutModel.controller.dispose();
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

class TestLayoutModel extends LayoutModel with TickerProviderLayout {
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
