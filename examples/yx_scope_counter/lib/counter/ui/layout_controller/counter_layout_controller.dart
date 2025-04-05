import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';
import 'package:yx_scope_counter/counter/exception/subtract_exception.dart';
import 'package:yx_scope_counter/counter/manager/counter_state_manager.dart';

import '../../../util/snack_bar_wrapper.dart';

part 'counter_layout_controller.factory.dart';

abstract interface class CounterLayoutController implements LayoutController {
  ValueListenable<int> get notifier;

  void add();

  void subtract();
}

final class CounterUILayoutController extends UILayoutController
    implements CounterLayoutController {
  final CounterStateManager _counterStateManager;
  final SnackBarWrapper _snackBarWrapper;

  late final ValueNotifier<int> _notifier = ValueNotifier(
    _counterStateManager.valueStream.value,
  );
  late StreamSubscription<int> _subscription;

  CounterUILayoutController({
    required CounterStateManager counterStateManager,
    required SnackBarWrapper snackBarWrapper,
  })  : _counterStateManager = counterStateManager,
        _snackBarWrapper = snackBarWrapper;

  @override
  ValueListenable<int> get notifier => _notifier;

  @override
  void init() {
    super.init();

    _subscription = _counterStateManager.valueStream.listen(
      (event) {
        _notifier.value = event;
      },
    );
  }

  @override
  void add() => _counterStateManager.add();

  @override
  void subtract() {
    try {
      _counterStateManager.subtract();
    } on SubtractException {
      _snackBarWrapper.show(
        context,
        snackBar: SnackBar(
          content: Text('Счетчик не может опуститься ниже 0'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _notifier.dispose();
    _subscription.cancel();
  }
}
