import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

import '../../../util/snack_bar_wrapper.dart';
import '../../exception/subtract_exception.dart';
import '../../manager/counter_state_manager.dart';

part 'counter_layout_model.factory.dart';

class CounterLayoutModel extends LayoutModel {
  final CounterStateManager _counterStateManager;
  final SnackBarWrapper _snackBarWrapper;

  late final ValueNotifier<int> _notifier = ValueNotifier(
    _counterStateManager.valueStream.value,
  );
  late StreamSubscription<int> _subscription;

  CounterLayoutModel({
    required CounterStateManager counterStateManager,
    required SnackBarWrapper snackBarWrapper,
  })  : _counterStateManager = counterStateManager,
        _snackBarWrapper = snackBarWrapper;

  ValueListenable<int> get listenable => _notifier;

  @override
  void init() {
    super.init();

    _subscription = _counterStateManager.valueStream.listen(
      (event) {
        _notifier.value = event;
      },
    );
  }

  void add() => _counterStateManager.add();

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
