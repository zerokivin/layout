import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late int factoryCalledCount;
  late Object? buildCallbackObject;
  late LayoutModelMock? layoutModel;
  late TestLayout layout;

  setUp(() {
    factoryCalledCount = 0;
    buildCallbackObject = null;
    layoutModel = null;

    void buildCallback(Object object) {
      buildCallbackObject = object;
    }

    layoutModel = LayoutModelMock();
    layout = TestLayout(
      TestLayoutModelFactory(
        layoutModel!,
        () {
          factoryCalledCount++;
        },
      ),
      buildCallback: buildCallback,
    );
  });

  testWidgets(
    'First build should create LayoutModel',
    (tester) async {
      await tester.pumpWidget(layout);

      expect(factoryCalledCount, 1);
    },
  );

  testWidgets(
    'Next builds should not create LayoutModel',
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
    'First build should call correct LayoutModel methods',
    (tester) async {
      await tester.pumpWidget(layout);

      verifyInOrder([
        () => layoutModel!.init(),
        () => layoutModel!.didChangeDependencies(),
      ]);
    },
  );

  testWidgets(
    'Element should use correct LayoutModel for building',
    (tester) async {
      await tester.pumpWidget(layout);

      expect(buildCallbackObject, same(layoutModel));
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
    'Unmount should call deactivate from LayoutModel',
    (tester) async {
      await tester.pumpWidget(layout);
      await tester.pumpWidget(Placeholder());

      verify(() => layoutModel!.deactivate()).called(1);
    },
  );

  testWidgets(
    'Unmount should call dispose from LayoutModel',
    (tester) async {
      await tester.pumpWidget(layout);
      await tester.pumpWidget(Placeholder());

      verify(() => layoutModel!.dispose()).called(1);
    },
  );

  testWidgets(
    'Moving to another part of tree should call activate from LayoutModel',
    (tester) async {
      void buildCallback(Object object) {
        buildCallbackObject = object;
      }

      layoutModel = LayoutModelMock();
      layout = TestLayout(
        TestLayoutModelFactory(
          layoutModel!,
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

      verify(() => layoutModel!.activate()).called(1);
    },
  );

  testWidgets(
    'Change dependencies should call didChangeDependencies LayoutModel',
    (tester) async {
      await tester.pumpWidget(
        TestNotifierScope(
          test: TestNotifier(),
          child: layout,
        ),
      );

      final element = tester.element<LayoutElement>(
        find.byElementType(LayoutElement),
      );

      verify(() => layoutModel!.didChangeDependencies()).called(1);

      TestNotifierScope.of(element).value++;

      await tester.pump();

      verify(() => layoutModel!.didChangeDependencies()).called(1);
    },
  );

  testWidgets(
    'Element should invoke LayoutModel didUpdateLayout after update',
    (tester) async {
      await tester.pumpWidget(layout);
      when(() => layoutModel!.layout).thenReturn(layout);

      final newLayout = TestLayout(
        TestLayoutModelFactory(
          LayoutModelMock(),
          () {},
        ),
        buildCallback: (_) {},
      );

      await tester.pumpWidget(newLayout);

      verify(() => layoutModel!.didUpdateLayout(layout)).called(1);
    },
  );

  testWidgets(
    'Element should have correct link with layout after update',
    (tester) async {
      await tester.pumpWidget(layout);
      when(() => layoutModel!.layout).thenReturn(layout);

      final element = tester.element<LayoutElement>(
        find.byElementType(LayoutElement),
      );

      final newLayout = TestLayout(
        TestLayoutModelFactory(
          LayoutModelMock(),
          () {},
        ),
        buildCallback: (_) {},
      );

      await tester.pumpWidget(newLayout);

      expect(element.widget, same(newLayout));
    },
  );

  testWidgets(
    'Element reassemble should invoke LayoutModel reassemble',
    (tester) async {
      await tester.pumpWidget(layout);

      final element = tester.element<LayoutElement>(
        find.byElementType(LayoutElement),
      );

      element.reassemble();

      verify(() => layoutModel!.reassemble()).called(1);
    },
  );

  testWidgets(
    'Debug fill properties should add LayoutModel',
    (tester) async {
      await tester.pumpWidget(layout);

      final element = tester.element<LayoutElement>(
        find.byElementType(LayoutElement),
      );

      final builder = DiagnosticPropertiesBuilder();
      element.debugFillProperties(builder);

      final props = builder.properties;
      final layoutModelProperty = props.firstWhereOrNull(
        (p) => p.name == 'layout_model',
      );

      expect(layoutModelProperty, isNotNull);
    },
  );
}

class TestLayout extends Layout {
  final void Function(Object) buildCallback;

  const TestLayout(
    super.layoutModelFactory, {
    required this.buildCallback,
    super.key,
  });

  @override
  Widget build(LayoutModelMock layoutModel) {
    buildCallback.call(layoutModel);

    return Placeholder();
  }
}

final class TestLayoutModelFactory implements LayoutModelFactory {
  final LayoutModelMock layoutModel;
  final VoidCallback factoryCalledCallback;

  TestLayoutModelFactory(
    this.layoutModel,
    this.factoryCalledCallback,
  );

  @override
  LayoutModelMock call() {
    factoryCalledCallback();

    return layoutModel;
  }
}

class LayoutModelMock extends DiagnosticableMock with MockLayoutModelMixin {}

abstract class DiagnosticableMock extends Mock with Diagnosticable {}

class TestNotifierScope extends InheritedNotifier<TestNotifier> {
  final TestNotifier test;

  const TestNotifierScope({
    required this.test,
    required super.child,
    super.key,
  }) : super(notifier: test);

  static TestNotifier of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<TestNotifierScope>();

    return scope!.notifier!;
  }
}

class TestNotifier extends ValueNotifier<int> {
  TestNotifier() : super(0);
}
