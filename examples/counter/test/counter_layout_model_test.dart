import 'package:counter/counter/layout_model/counter_layout_model.dart';
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

  testLayoutModel<CounterLayoutModel>(
    'counter initial state',
    () => CounterLayoutModel(),
    (layoutModel, tester, context) {
      expect(layoutModel.listenable.value, 0);
    },
  );

  testLayoutModel<CounterLayoutModel>(
    'counter add',
    () => CounterLayoutModel(),
    (layoutModel, tester, context) async {
      layoutModel.add();
      expect(layoutModel.listenable.value, 1);
    },
  );

  testLayoutModel<CounterLayoutModel>(
    'counter subtract',
    () => CounterLayoutModel(),
    (layoutModel, tester, context) async {
      layoutModel.add();
      layoutModel.subtract();
      expect(layoutModel.listenable.value, 0);
    },
  );

  testLayoutModel<CounterLayoutModel>(
    'counter subtract less then 0',
    () => CounterLayoutModel(
      snackBarWrapper: snackBarWrapperMock,
    ),
    (layoutModel, tester, context) async {
      tester.init();
      layoutModel.subtract();
      expect(layoutModel.listenable.value, 0);
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
