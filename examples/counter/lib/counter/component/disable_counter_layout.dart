import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

import '../counter_layout_controller.dart';
import '../counter_layout_controller_factory.dart';

class DisableCounterLayout extends Layout {
  const DisableCounterLayout({
    super.key,
  }) : super(const CounterLayoutControllerFactory());

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
            ValueListenableBuilder(
              valueListenable: layoutController.notifier,
              builder: (_, value, __) {
                VoidCallback? onPressed;
                if (value > 0) {
                  onPressed = () => layoutController.subtract();
                }

                return FilledButton(
                  onPressed: onPressed,
                  child: Icon(Icons.remove),
                );
              },
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
