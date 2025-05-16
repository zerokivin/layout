import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';

void main() {
  late TestLayoutModel layoutModel;

  group('In tree interaction.', () {
    late TestLayout layout;

    setUp(() {
      layoutModel = TestLayoutModel();
      layout = TestLayout(
        TestLayoutModelFactory(layoutModel),
      );
    });

    testWidgets(
      'Getter context should return correct Element',
      (tester) async {
        await tester.pumpWidget(layout);

        final element = tester.element<LayoutElement>(
          find.byElementType(LayoutElement),
        );

        expect(layoutModel.context, same(element));
      },
    );

    testWidgets(
      'Getting context after unmount should throw error',
      (tester) async {
        await tester.pumpWidget(layout);
        await tester.pumpWidget(Placeholder());

        FlutterError? error;

        try {
          layoutModel.context;
        } on FlutterError catch (e) {
          error = e;
        }

        expect(error, isNotNull);
        expect(error!.message, 'This layoutModel has been unmounted');
      },
    );

    testWidgets(
      'Getting context before mount should throw error',
      (tester) async {
        FlutterError? error;

        try {
          layoutModel.context;
        } on FlutterError catch (e) {
          error = e;
        }

        expect(error, isNotNull);
        expect(error!.message, 'This layoutModel has been unmounted');
      },
    );

    testWidgets(
      'Property isMounted should return true when layout inflate into tree',
      (tester) async {
        await tester.pumpWidget(layout);

        expect(layoutModel.isMounted, isTrue);
      },
    );

    testWidgets(
      'Property isMounted should return false after defunct',
      (tester) async {
        await tester.pumpWidget(layout);
        await tester.pumpWidget(Placeholder());

        expect(layoutModel.isMounted, isFalse);
      },
    );

    testWidgets(
      'Getter layout should return correct layout',
      (tester) async {
        await tester.pumpWidget(layout);

        expect(layoutModel.layout, same(layout));
      },
    );

    testWidgets(
      'Getting layout after unmount should throw error',
      (tester) async {
        await tester.pumpWidget(layout);
        await tester.pumpWidget(Placeholder());

        FlutterError? error;

        try {
          layoutModel.layout;
        } on FlutterError catch (e) {
          error = e;
        }

        expect(error, isNotNull);
        expect(error!.message, 'This layoutModel has been unmounted');
      },
    );
  });

  group('Testing methods', () {
    setUp(() {
      layoutModel = TestLayoutModel();
    });

    test(
      'setupTestLayout should set layout',
      () {
        final layout = TestLayout(
          TestLayoutModelFactory(layoutModel),
        );

        layoutModel.setupTestLayout(layout);

        expect(layoutModel.layout, same(layout));
      },
    );

    test(
      'setupTestElement should set element',
      () {
        final layout = TestLayout(
          TestLayoutModelFactory(layoutModel),
        );
        final element = LayoutElement(layout);

        layoutModel.setupTestElement(element);

        expect(layoutModel.context, same(element));
      },
    );
  });
}

class TestLayout extends Layout {
  const TestLayout(
    super.layoutModelFactory, {
    super.key,
  });

  @override
  Widget build(TestLayoutModel layoutModel) {
    return Placeholder();
  }
}

final class TestLayoutModelFactory implements LayoutModelFactory {
  final TestLayoutModel layoutModel;

  TestLayoutModelFactory(
    this.layoutModel,
  );

  @override
  TestLayoutModel call() => layoutModel;
}

class TestLayoutModel extends LayoutModel {}
