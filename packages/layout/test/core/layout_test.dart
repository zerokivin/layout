import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';

void main() {
  late TestLayout layout;

  setUp(() {
    layout = const TestLayout();
  });

  test('UILayout should create correct type element', () {
    final result = layout.createElement();

    expect(result, const TypeMatcher<LayoutElement>());
  });
}

class TestLayout extends Layout {
  const TestLayout({
    super.key,
  }) : super(const TestLayoutControllerFactory());

  @override
  Widget build(TestUILayoutController layoutController) {
    return Placeholder();
  }
}

final class TestLayoutControllerFactory implements LayoutControllerFactory {
  const TestLayoutControllerFactory();

  @override
  BaseLayoutController call() => TestUILayoutController();
}

final class TestUILayoutController extends UILayoutController {}
