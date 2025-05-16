import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

import '../../util/snack_bar_wrapper.dart';

part 'counter_layout_model.factory.dart';

class CounterLayoutModel extends LayoutModel {
  final SnackBarWrapper _snackBarWrapper;

  final ValueNotifier<int> _notifier = ValueNotifier(0);

  CounterLayoutModel({
    SnackBarWrapper snackBarWrapper = const SnackBarWrapper(),
  }) : _snackBarWrapper = snackBarWrapper;

  ValueListenable<int> get listenable => _notifier;

  void add() {
    _notifier.value += 1;
  }

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
