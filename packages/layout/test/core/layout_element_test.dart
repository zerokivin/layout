import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late int factoryCalledCount;
  late Object? buildCallbackObject;
  late LayoutControllerMock? layoutController;
  late TestLayout layout;

  setUp(() {
    factoryCalledCount = 0;
    buildCallbackObject = null;
    layoutController = null;

    void buildCallback(Object object) {
      buildCallbackObject = object;
    }

    layoutController = LayoutControllerMock();
    layout = TestLayout(
      TestLayoutControllerFactory(
        layoutController!,
        () {
          factoryCalledCount++;
        },
      ),
      buildCallback: buildCallback,
    );
  });

  testWidgets(
    'First build should create LayoutController',
    (tester) async {
      await tester.pumpWidget(layout);

      expect(factoryCalledCount, 1);
    },
  );

  testWidgets(
    'Next builds should not create LayoutController',
    (tester) async {
      await tester.pumpWidget(layout);

      expect(factoryCalledCount, 1);

      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(factoryCalledCount, 1);
    },
  );

  testWidgets(
    'First build should call correct LayoutController methods',
    (tester) async {
      await tester.pumpWidget(layout);

      verifyInOrder([
        () => layoutController!.init(),
        () => layoutController!.didChangeDependencies(),
      ]);
    },
  );

  testWidgets(
    'Element should use correct LayoutController for building',
    (tester) async {
      await tester.pumpWidget(layout);

      expect(buildCallbackObject, same(layoutController));
    },
  );

  testWidgets(
    'Element should have correct link with layout',
    (tester) async {
      await tester.pumpWidget(layout);

      final element = tester.element<LayoutElement>(
        find.byElementType(LayoutElement),
      );

      expect(element.widget, same(layout));
    },
  );

  testWidgets(
    'Unmount should call deactivate from LayoutController',
    (tester) async {
      await tester.pumpWidget(layout);
      await tester.pumpWidget(Placeholder());

      verify(() => layoutController!.deactivate()).called(1);
    },
  );

  testWidgets(
    'Unmount should call dispose from LayoutController',
    (tester) async {
      await tester.pumpWidget(layout);
      await tester.pumpWidget(Placeholder());

      verify(() => layoutController!.dispose()).called(1);
    },
  );

  testWidgets(
    'Moving to another part of tree should call activate from LayoutController',
    (tester) async {
      void buildCallback(Object object) {
        buildCallbackObject = object;
      }

      layoutController = LayoutControllerMock();
      layout = TestLayout(
        TestLayoutControllerFactory(
          layoutController!,
          () {
            factoryCalledCount++;
          },
        ),
        key: GlobalKey(debugLabel: 'test'),
        buildCallback: buildCallback,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              Row(
                key: const ValueKey<String>('firstRow'),
                children: [
                  layout,
                ],
              ),
              const Row(
                key: ValueKey<String>('secondRow'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              const Row(
                key: ValueKey<String>('firstRow'),
              ),
              Row(
                key: const ValueKey<String>('secondRow'),
                children: [
                  layout,
                ],
              ),
            ],
          ),
        ),
      );

      verify(() => layoutController!.activate()).called(1);
    },
  );

  testWidgets(
    'Change dependencies should call didChangeDependencies LayoutController',
    (tester) async {
      final notifier = TestNotifier();

      await tester.pumpWidget(
        TestNotifierWidget(
          test: notifier,
          child: layout,
        ),
      );

      final element = tester.element<LayoutElement>(
        find.byElementType(LayoutElement),
      );

      verify(() => layoutController!.didChangeDependencies()).called(1);

      TestNotifierWidget.of(element);

      notifier.up();

      await tester.pump();

      verify(() => layoutController!.didChangeDependencies()).called(1);
    },
  );

  testWidgets(
    'Element should invoke LayoutController didUpdateLayout after update',
    (tester) async {
      await tester.pumpWidget(layout);
      when(() => layoutController!.layout).thenReturn(layout);

      final newLayout = TestLayout(
        TestLayoutControllerFactory(
          LayoutControllerMock(),
          () {},
        ),
        buildCallback: (_) {},
      );

      await tester.pumpWidget(newLayout);

      verify(() => layoutController!.didUpdateLayout(layout)).called(1);
    },
  );

  testWidgets(
    'Element should have correct link with layout after update',
    (tester) async {
      await tester.pumpWidget(layout);
      when(() => layoutController!.layout).thenReturn(layout);

      final element = tester.element<LayoutElement>(
        find.byElementType(LayoutElement),
      );

      final newLayout = TestLayout(
        TestLayoutControllerFactory(
          LayoutControllerMock(),
          () {},
        ),
        buildCallback: (_) {},
      );

      await tester.pumpWidget(newLayout);

      expect(element.widget, same(newLayout));
    },
  );

  testWidgets(
    'Element reassemble should invoke LayoutController reassemble',
    (tester) async {
      await tester.pumpWidget(layout);

      final element = tester.element<LayoutElement>(
        find.byElementType(LayoutElement),
      );

      element.reassemble();

      verify(() => layoutController!.reassemble()).called(1);
    },
  );

  testWidgets(
    'Debug fill properties should add LayoutController',
    (tester) async {
      await tester.pumpWidget(layout);

      final element = tester.element<LayoutElement>(
        find.byElementType(LayoutElement),
      );

      final builder = DiagnosticPropertiesBuilder();
      element.debugFillProperties(builder);

      final props = builder.properties;
      final layoutControllerProperty = props.firstWhereOrNull(
        (p) => p.name == 'layout_controller',
      );

      expect(layoutControllerProperty, isNotNull);
    },
  );
}

class TestLayout extends Layout {
  final void Function(Object) buildCallback;

  const TestLayout(
    super.layoutControllerFactory, {
    required this.buildCallback,
    super.key,
  });

  @override
  Widget build(LayoutControllerMock layoutController) {
    buildCallback.call(layoutController);

    return Placeholder();
  }
}

final class TestLayoutControllerFactory implements LayoutControllerFactory {
  final LayoutControllerMock layoutController;
  final VoidCallback factoryCalledCallback;

  TestLayoutControllerFactory(
    this.layoutController,
    this.factoryCalledCallback,
  );

  @override
  BaseLayoutController call() {
    factoryCalledCallback();

    return layoutController;
  }
}

final class LayoutControllerMock extends DiagnosticableMock
    with MockLayoutControllerMixin {}

abstract class DiagnosticableMock extends Mock with Diagnosticable {}

class TestNotifierWidget extends InheritedNotifier {
  final TestNotifier test;

  const TestNotifierWidget({
    required this.test,
    required super.child,
    super.key,
  }) : super(notifier: test);

  static TestNotifier of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<TestNotifierWidget>();

    if (widget == null) {
      throw Exception('Not found');
    }

    return widget.test;
  }
}

class TestNotifier extends ValueNotifier<int> {
  TestNotifier() : super(0);

  void up() {
    value++;
  }
}
