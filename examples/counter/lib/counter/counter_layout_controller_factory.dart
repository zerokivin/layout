import 'package:layout/layout.dart';

import 'counter_layout_controller.dart';

final class CounterLayoutControllerFactory implements LayoutControllerFactory {
  const CounterLayoutControllerFactory();

  @override
  BaseLayoutController call() => CounterUILayoutController();
}
