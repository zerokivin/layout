import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';

void main() {
  late TestUILayoutController layoutController;

  group('In tree interaction.', () {
    late TestLayout layout;

    setUp(() {
      layoutController = TestUILayoutController();
      layout = TestLayout(
        TestLayoutControllerFactory(layoutController),
      );
    });

    testWidgets(
      'Getter cupertinoTheme should return correct CupertinoThemeData',
      (tester) async {
        CupertinoThemeData? actualTheme;

        await tester.pumpWidget(
          CupertinoTheme(
            data: const CupertinoThemeData(),
            child: Builder(
              builder: (context) {
                actualTheme = CupertinoTheme.of(context);

                return layout;
              },
            ),
          ),
        );

        expect(layoutController.cupertinoTheme, equals(actualTheme));
      },
    );

    testWidgets(
      'Getter defaultAssetBundle should return correct AssetBundle',
      (tester) async {
        final assetBundle = PlatformAssetBundle();
        await tester.pumpWidget(
          DefaultAssetBundle(
            bundle: assetBundle,
            child: layout,
          ),
        );

        expect(layoutController.defaultAssetBundle, same(assetBundle));
      },
    );

    testWidgets(
      'Getter defaultTextStyle should return correct DefaultTextStyle',
      (tester) async {
        final textStyle = TextStyle();
        await tester.pumpWidget(
          DefaultTextStyle(
            style: textStyle,
            child: layout,
          ),
        );

        expect(layoutController.defaultTextStyle.style, same(textStyle));
      },
    );

    testWidgets(
      'Getter mediaQuery should return correct MediaQueryData',
      (tester) async {
        final mediaQueryData = MediaQueryData();
        await tester.pumpWidget(
          MediaQuery(
            data: mediaQueryData,
            child: layout,
          ),
        );

        expect(layoutController.mediaQuery, same(mediaQueryData));
      },
    );

    testWidgets(
      'Getter directionality should return correct TextDirection',
      (tester) async {
        final textDirection = TextDirection.rtl;
        await tester.pumpWidget(
          Directionality(
            textDirection: textDirection,
            child: layout,
          ),
        );

        expect(layoutController.directionality, same(textDirection));
      },
    );

    testWidgets(
      'Getter theme should return correct ThemeData',
      (tester) async {
        ThemeData? actualTheme;

        await tester.pumpWidget(
          Theme(
            data: ThemeData(),
            child: Builder(
              builder: (context) {
                actualTheme = Theme.of(context);

                return layout;
              },
            ),
          ),
        );

        expect(layoutController.theme, equals(actualTheme));
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
  Widget build(TestUILayoutController layoutController) {
    return Placeholder();
  }
}

final class TestLayoutControllerFactory implements LayoutControllerFactory {
  final TestUILayoutController layoutController;

  TestLayoutControllerFactory(this.layoutController);

  @override
  BaseLayoutController call() => layoutController;
}

final class TestUILayoutController extends UILayoutController {}
