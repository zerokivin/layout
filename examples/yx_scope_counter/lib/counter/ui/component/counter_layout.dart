import 'package:flutter/material.dart';
import 'package:layout/layout.dart';
import 'package:yx_scope_counter/counter/ui/counter_layout_controller_factory.dart';

import '../counter_layout_controller.dart';

class CounterLayout extends Layout {
  const CounterLayout(
    CounterLayoutControllerFactory super.layoutControllerFactory, {
    super.key,
  });

  @override
  Widget build(CounterLayoutController layoutController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: layoutController.notifier,
          builder: (_, value, __) {
            return Text('$value');
          },
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              onPressed: () => layoutController.subtract(),
              child: Icon(Icons.remove),
            ),
            SizedBox(
              width: 16,
            ),
            FilledButton(
              onPressed: () => layoutController.add(),
              child: Icon(Icons.add),
            ),
          ],
        )
      ],
    );
  }
}
