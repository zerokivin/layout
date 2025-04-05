import 'package:flutter_test/flutter_test.dart';
import 'package:yx_scope_counter/counter/exception/subtract_exception.dart';
import 'package:yx_scope_counter/counter/manager/counter_state_manager.dart';

void main() {
  late CounterStateManager counterStateManager;

  setUp(() {
    counterStateManager = CounterStateManager.create();
  });

  test(
    'counter initial state',
    () {
      expect(counterStateManager.valueStream.value, 0);
    },
  );

  test(
    'counter add',
    () async {
      counterStateManager.add();
      expect(counterStateManager.valueStream.value, 1);
    },
  );

  test(
    'counter subtract',
    () async {
      counterStateManager.add();
      counterStateManager.subtract();
      expect(counterStateManager.valueStream.value, 0);
    },
  );

  test(
    'counter subtract less then 0',
    () async {
      Object? error;

      try {
        counterStateManager.subtract();
      } catch (e) {
        error = e;
      }

      expect(counterStateManager.valueStream.value, 0);
      expect(error, isA<SubtractException>());
    },
  );
}
