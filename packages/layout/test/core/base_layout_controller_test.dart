import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';

void main() {
  late TestLayoutController layoutController;

  group('In tree interaction.', () {
    late TestLayout layout;

    setUp(() {
      layoutController = TestLayoutController();
      layout = TestLayout(
        TestLayoutControllerFactory(layoutController),
      );
    });

    testWidgets(
      'Getter context should return correct Element',
      (tester) async {
        await tester.pumpWidget(layout);

        final element = tester.element<LayoutElement>(
          find.byElementType(LayoutElement),
        );

        expect(layoutController.context, same(element));
      },
    );

    testWidgets(
      'Getting context after unmount should throw error',
      (tester) async {
        await tester.pumpWidget(layout);
        await tester.pumpWidget(Placeholder());

        FlutterError? error;

        try {
          layoutController.context;
        } on FlutterError catch (e) {
          error = e;
        }

        expect(error, isNotNull);
        expect(error!.message, 'This LayoutController has been unmounted');
      },
    );

    testWidgets(
      'Getting context before mount should throw error',
      (tester) async {
        FlutterError? error;

        try {
          layoutController.context;
        } on FlutterError catch (e) {
          error = e;
        }

        expect(error, isNotNull);
        expect(error!.message, 'This LayoutController has been unmounted');
      },
    );

    testWidgets(
      'Property isMounted should return true when layout inflate into tree',
      (tester) async {
        await tester.pumpWidget(layout);

        expect(layoutController.isMounted, isTrue);
      },
    );

    testWidgets(
      'Property isMounted should return false after defunct',
      (tester) async {
        await tester.pumpWidget(layout);
        await tester.pumpWidget(Placeholder());

        expect(layoutController.isMounted, isFalse);
      },
    );

    testWidgets(
      'Getter layout should return correct layout',
      (tester) async {
        await tester.pumpWidget(layout);

        expect(layoutController.layout, same(layout));
      },
    );

    testWidgets(
      'Getting layout after unmount should throw error',
      (tester) async {
        await tester.pumpWidget(layout);
        await tester.pumpWidget(Placeholder());

        FlutterError? error;

        try {
          layoutController.layout;
        } on FlutterError catch (e) {
          error = e;
        }

        expect(error, isNotNull);
        expect(error!.message, 'This LayoutController has been unmounted');
      },
    );
  });

  group('Testing methods', () {
    setUp(() {
      layoutController = TestLayoutController();
    });

    test(
      'setupTestLayout should set layout',
      () {
        final layout = TestLayout(
          TestLayoutControllerFactory(layoutController),
        );

        layoutController.setupTestLayout(layout);

        expect(layoutController.layout, same(layout));
      },
    );

    test(
      'setupTestElement should set element',
      () {
        final layout = TestLayout(
          TestLayoutControllerFactory(layoutController),
        );
        final element = LayoutElement(layout);

        layoutController.setupTestElement(element);

        expect(layoutController.context, same(element));
      },
    );
  });
}

class TestLayout extends Layout {
  const TestLayout(
    super.layoutControllerFactory, {
    super.key,
  });

  @override
  Widget build(TestLayoutController layoutController) {
    return Placeholder();
  }
}

final class TestLayoutControllerFactory implements LayoutControllerFactory {
  final TestLayoutController layoutController;

  TestLayoutControllerFactory(this.layoutController);

  @override
  BaseLayoutController call() => layoutController;
}

final class TestLayoutController extends BaseLayoutController {
  @override
  CupertinoThemeData get cupertinoTheme => throw UnimplementedError();

  @override
  AssetBundle get defaultAssetBundle => throw UnimplementedError();

  @override
  DefaultTextStyle get defaultTextStyle => throw UnimplementedError();

  @override
  MediaQueryData get mediaQuery => throw UnimplementedError();

  @override
  TextDirection get directionality => throw UnimplementedError();

  @override
  ThemeData get theme => throw UnimplementedError();
}
