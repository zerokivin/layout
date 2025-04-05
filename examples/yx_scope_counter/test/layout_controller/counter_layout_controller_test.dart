import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout_test/layout_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yx_scope_counter/counter/exception/subtract_exception.dart';
import 'package:yx_scope_counter/counter/manager/counter_state_manager.dart';
import 'package:yx_scope_counter/counter/ui/counter_layout_controller.dart';
import 'package:yx_scope_counter/util/snack_bar_wrapper.dart';

void main() {
  late SnackBarWrapperMock snackBarWrapperMock;
  late CounterStateManagerMock counterStateManagerMock;

  setUpAll(() {
    registerFallbackValue(SnackBarFake());
  });

  setUp(() {
    snackBarWrapperMock = SnackBarWrapperMock();
    counterStateManagerMock = CounterStateManagerMock();
  });

  testLayoutController<CounterUILayoutController>(
    'counter initial state',
    () => CounterUILayoutController(
      counterStateManager: counterStateManagerMock,
      snackBarWrapper: snackBarWrapperMock,
    ),
    (layoutController, tester, context) {
      when(() => counterStateManagerMock.valueStream).thenAnswer(
        (_) => BehaviorSubject.seeded(0),
      );

      expect(layoutController.notifier.value, 0);
    },
  );

  testLayoutController<CounterUILayoutController>(
    'counter add',
    () => CounterUILayoutController(
      counterStateManager: counterStateManagerMock,
      snackBarWrapper: snackBarWrapperMock,
    ),
    (layoutController, tester, context) async {
      layoutController.add();
      verify(() => counterStateManagerMock.add()).called(1);
    },
  );

  testLayoutController<CounterUILayoutController>(
    'counter subtract',
    () => CounterUILayoutController(
      counterStateManager: counterStateManagerMock,
      snackBarWrapper: snackBarWrapperMock,
    ),
    (layoutController, tester, context) async {
      layoutController.subtract();
      verify(() => counterStateManagerMock.subtract()).called(1);
    },
  );

  testLayoutController<CounterUILayoutController>(
    'counter subtract less then 0',
    () => CounterUILayoutController(
      counterStateManager: counterStateManagerMock,
      snackBarWrapper: snackBarWrapperMock,
    ),
    (layoutController, tester, context) async {
      when(() => counterStateManagerMock.valueStream).thenAnswer(
        (_) => BehaviorSubject.seeded(0),
      );
      when(() => counterStateManagerMock.subtract()).thenThrow(
        SubtractException(),
      );

      tester.init();
      layoutController.subtract();

      verify(
        () => snackBarWrapperMock.show(
          context,
          snackBar: any<SnackBar>(named: 'snackBar'),
        ),
      ).called(1);
    },
  );
}

class CounterStateManagerMock extends Mock implements CounterStateManager {}

class SnackBarWrapperMock extends Mock implements SnackBarWrapper {}

class SnackBarFake extends DiagnosticableFake implements SnackBar {}

abstract class DiagnosticableFake extends Fake with Diagnosticable {}
