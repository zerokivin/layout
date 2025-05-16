import 'package:flutter/material.dart';
import 'package:layout/layout.dart';

import '../layout_model/counter_layout_model.dart';

class CounterLayout extends Layout {
  const CounterLayout(
    CounterLayoutModelFactory super.layoutModelFactory, {
    super.key,
  });

  @override
  Widget build(CounterLayoutModel layoutModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: layoutModel.listenable,
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
              onPressed: () => layoutModel.subtract(),
              child: Icon(Icons.remove),
            ),
            SizedBox(
              width: 16,
            ),
            FilledButton(
              onPressed: () => layoutModel.add(),
              child: Icon(Icons.add),
            ),
          ],
        )
      ],
    );
  }
}
