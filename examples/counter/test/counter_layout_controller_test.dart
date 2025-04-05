import 'package:counter/counter/layout_controller/counter_layout_controller.dart';
import 'package:counter/util/snack_bar_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout_test/layout_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late SnackBarWrapperMock snackBarWrapperMock;

  setUpAll(() {
    registerFallbackValue(SnackBarFake());
  });

  setUp(() {
    snackBarWrapperMock = SnackBarWrapperMock();
  });

  testLayoutController<CounterUILayoutController>(
    'counter initial state',
    () => CounterUILayoutController(),
    (layoutController, tester, context) {
      expect(layoutController.notifier.value, 0);
    },
  );

  testLayoutController<CounterUILayoutController>(
    'counter add',
    () => CounterUILayoutController(),
    (layoutController, tester, context) async {
      layoutController.add();
      expect(layoutController.notifier.value, 1);
    },
  );

  testLayoutController<CounterUILayoutController>(
    'counter subtract',
    () => CounterUILayoutController(),
    (layoutController, tester, context) async {
      layoutController.add();
      layoutController.subtract();
      expect(layoutController.notifier.value, 0);
    },
  );

  testLayoutController<CounterUILayoutController>(
    'counter subtract less then 0',
    () => CounterUILayoutController(
      snackBarWrapper: snackBarWrapperMock,
    ),
    (layoutController, tester, context) async {
      tester.init();
      layoutController.subtract();
      expect(layoutController.notifier.value, 0);
      verify(
        () => snackBarWrapperMock.show(
          context,
          snackBar: any<SnackBar>(named: 'snackBar'),
        ),
      ).called(1);
    },
  );
}

final class SnackBarWrapperMock extends Mock implements SnackBarWrapper {}

final class SnackBarFake extends DiagnosticableFake implements SnackBar {}

abstract class DiagnosticableFake extends Fake with Diagnosticable {}
