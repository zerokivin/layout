import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout_test/layout_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rxdart/rxdart.dart';
import 'package:yx_scope_counter/counter/exception/subtract_exception.dart';
import 'package:yx_scope_counter/counter/manager/counter_state_manager.dart';
import 'package:yx_scope_counter/counter/ui/layout_model/counter_layout_model.dart';
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

  testLayoutModel<CounterLayoutModel>(
    'counter initial state',
    () => CounterLayoutModel(
      counterStateManager: counterStateManagerMock,
      snackBarWrapper: snackBarWrapperMock,
    ),
    (layoutModel, tester, context) {
      when(() => counterStateManagerMock.valueStream).thenAnswer(
        (_) => BehaviorSubject.seeded(0),
      );

      expect(layoutModel.listenable.value, 0);
    },
  );

  testLayoutModel<CounterLayoutModel>(
    'counter add',
    () => CounterLayoutModel(
      counterStateManager: counterStateManagerMock,
      snackBarWrapper: snackBarWrapperMock,
    ),
    (layoutModel, tester, context) async {
      layoutModel.add();
      verify(() => counterStateManagerMock.add()).called(1);
    },
  );

  testLayoutModel<CounterLayoutModel>(
    'counter subtract',
    () => CounterLayoutModel(
      counterStateManager: counterStateManagerMock,
      snackBarWrapper: snackBarWrapperMock,
    ),
    (layoutModel, tester, context) async {
      layoutModel.subtract();
      verify(() => counterStateManagerMock.subtract()).called(1);
    },
  );

  testLayoutModel<CounterLayoutModel>(
    'counter subtract less then 0',
    () => CounterLayoutModel(
      counterStateManager: counterStateManagerMock,
      snackBarWrapper: snackBarWrapperMock,
    ),
    (layoutModel, tester, context) async {
      when(() => counterStateManagerMock.valueStream).thenAnswer(
        (_) => BehaviorSubject.seeded(0),
      );
      when(() => counterStateManagerMock.subtract()).thenThrow(
        SubtractException(),
      );

      tester.init();
      layoutModel.subtract();

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
