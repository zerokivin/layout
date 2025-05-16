import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';

void main() {
  late TestLayout layout;

  setUp(() {
    layout = const TestLayout();
  });

  test('Layout should create correct type element', () {
    final result = layout.createElement();

    expect(result, const TypeMatcher<LayoutElement>());
  });
}

class TestLayout extends Layout {
  const TestLayout({
    super.key,
  }) : super(const TestLayoutModelFactory());

  @override
  Widget build(TestLayoutModel layoutModel) {
    return MaterialApp(
      home: Scaffold(
        body: Placeholder(),
      ),
    );
  }
}

final class TestLayoutModelFactory implements LayoutModelFactory {
  const TestLayoutModelFactory();

  @override
  TestLayoutModel call() => TestLayoutModel();
}

class TestLayoutModel extends LayoutModel {}
