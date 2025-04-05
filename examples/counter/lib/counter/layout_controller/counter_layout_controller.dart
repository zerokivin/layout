import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

import '../../util/snack_bar_wrapper.dart';

part 'counter_layout_controller.factory.dart';

abstract interface class CounterLayoutController implements LayoutController {
  ValueListenable<int> get notifier;

  void add();

  void subtract();
}

final class CounterUILayoutController extends UILayoutController
    implements CounterLayoutController {
  final SnackBarWrapper _snackBarWrapper;

  final ValueNotifier<int> _notifier = ValueNotifier(0);

  CounterUILayoutController({
    SnackBarWrapper snackBarWrapper = const SnackBarWrapper(),
  }) : _snackBarWrapper = snackBarWrapper;

  @override
  ValueListenable<int> get notifier => _notifier;

  @override
  void add() {
    _notifier.value += 1;
  }

  @override
  void subtract() {
    if (_notifier.value == 0) {
      _snackBarWrapper.show(
        context,
        snackBar: SnackBar(
          content: Text('Счетчик не может опуститься ниже 0'),
        ),
      );
    } else {
      _notifier.value -= 1;
    }
  }

  @override
  void dispose() {
    _notifier.dispose();
  }
}
