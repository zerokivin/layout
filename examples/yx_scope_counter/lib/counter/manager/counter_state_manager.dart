import 'package:rxdart/rxdart.dart';
import 'package:yx_scope/yx_scope.dart';

import '../exception/subtract_exception.dart';

abstract interface class CounterStateManager implements AsyncLifecycle {
  factory CounterStateManager.create() = _Impl;

  ValueStream<int> get valueStream;

  void add();

  void subtract();
}

class _Impl implements CounterStateManager {
  final BehaviorSubject<int> _subject = BehaviorSubject.seeded(0);

  @override
  ValueStream<int> get valueStream => _subject;

  @override
  Future<void> init() async {}

  @override
  void add() {
    _subject.value += 1;
  }

  @override
  void subtract() {
    if (_subject.value == 0) {
      throw SubtractException();
    } else {
      _subject.value -= 1;
    }
  }

  @override
  Future<void> dispose() async {
    _subject.close();
  }
}
