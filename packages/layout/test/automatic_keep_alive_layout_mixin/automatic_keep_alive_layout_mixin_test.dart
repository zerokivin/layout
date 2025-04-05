import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';

const firstWidgetKey = Key('Test key first');
const lastWidgetKey = Key('Test key second');
const listViewKey = Key('ListView key');
const tabBarViewKey = Key('TabBarView key');
const firstTabKey = Key('First tab key');
const secondTabKey = Key('Second tab key');

void main() {
  late TestUILayoutController layoutController;
  late TestLayout layout;
  late ScrollController scrollController;
  late TabController tabController;
  late Widget widget;

  const listViewContent = [
    SizedBox(
      key: firstWidgetKey,
      height: 200,
      width: double.infinity,
    ),
    SizedBox(
      height: 200,
      width: double.infinity,
    ),
    SizedBox(
      height: 200,
      width: double.infinity,
    ),
    SizedBox(
      height: 200,
      width: double.infinity,
    ),
    SizedBox(
      height: 200,
      width: double.infinity,
    ),
    SizedBox(
      key: lastWidgetKey,
      height: 200,
      width: double.infinity,
    ),
  ];

  setUp(
    () {
      scrollController = ScrollController();
      layout = TestLayout(
        TestLayoutControllerFactory(
          () => layoutController,
        ),
        controller: scrollController,
        listViewContent: listViewContent,
        key: firstTabKey,
      );
      tabController = TabController(
        length: 2,
        vsync: const TestVSync(),
      );
    },
  );

  testWidgets(
    'When switching between tabs, the state of the tabs should be preserved',
    (tester) async {
      layoutController = TestUILayoutController();
      widget = TestTabScreen(
        layout,
        tabController,
        key: tabBarViewKey,
      );
      await tester.pumpWidget(widget);

      // During initialization, the first tab with the
      // beginning of the listViewContent should be displayed.
      expect(find.byKey(firstTabKey), findsOneWidget);
      expect(find.byKey(secondTabKey), findsNothing);
      expect(find.byKey(firstWidgetKey), findsOneWidget);
      expect(find.byKey(lastWidgetKey), findsNothing);

      // Scroll to the end of the listViewContent.
      await tester.drag(find.byKey(listViewKey), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Last widget from the listViewContent should be displayed.
      expect(find.byKey(firstWidgetKey), findsNothing);
      expect(find.byKey(lastWidgetKey), findsOneWidget);

      // Switching between tabs(go to the second tab).
      await tester.drag(find.byKey(tabBarViewKey), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // After switching the second tab should be displayed.
      expect(find.byKey(firstTabKey), findsNothing);
      expect(find.byKey(secondTabKey), findsOneWidget);
      expect(find.byKey(firstWidgetKey), findsNothing);
      expect(find.byKey(lastWidgetKey), findsNothing);

      // Switching between tabs(back to the first tab).
      await tester.drag(find.byKey(tabBarViewKey), const Offset(500, 0));
      await tester.pumpAndSettle();

      // Last widget of the listViewContent on the first tab should be
      // displayed.
      expect(find.byKey(firstTabKey), findsOneWidget);
      expect(find.byKey(secondTabKey), findsNothing);
      expect(find.byKey(firstWidgetKey), findsNothing);
      expect(find.byKey(lastWidgetKey), findsOneWidget);
    },
  );

  testWidgets(
    'If disable saving state of the layoutController, then when switching '
    'between tabs, their state should not be saved',
    (tester) async {
      layoutController = TestUILayoutController();
      widget = TestTabScreen(
        layout,
        tabController,
        key: tabBarViewKey,
      );
      await tester.pumpWidget(widget);

      layoutController.setupWantKeepAlive(false);

      // During initialization, the first tab with the
      // beginning of the listViewContent should be displayed.
      expect(find.byKey(firstTabKey), findsOneWidget);
      expect(find.byKey(secondTabKey), findsNothing);
      expect(find.byKey(firstWidgetKey), findsOneWidget);
      expect(find.byKey(lastWidgetKey), findsNothing);

      // Scroll to the end of the listViewContent.
      await tester.drag(find.byKey(listViewKey), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Last widget from the listViewContent should be displayed.
      expect(find.byKey(firstWidgetKey), findsNothing);
      expect(find.byKey(lastWidgetKey), findsOneWidget);

      // Switching between tabs(go to the second tab).
      await tester.drag(find.byKey(tabBarViewKey), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // After switching the second tab should be displayed.
      expect(find.byKey(firstTabKey), findsNothing);
      expect(find.byKey(secondTabKey), findsOneWidget);
      expect(find.byKey(firstWidgetKey), findsNothing);
      expect(find.byKey(lastWidgetKey), findsNothing);

      // Switching between tabs(back to the first tab).
      await tester.drag(find.byKey(tabBarViewKey), const Offset(500, 0));
      await tester.pumpAndSettle();

      // First widget of the listViewContent on the first tab should be
      // displayed.
      expect(find.byKey(firstTabKey), findsOneWidget);
      expect(find.byKey(secondTabKey), findsNothing);
      expect(find.byKey(firstWidgetKey), findsOneWidget);
      expect(find.byKey(lastWidgetKey), findsNothing);
    },
  );

  testWidgets(
    'Switching wantKeepAlive from true(default) to false should change '
    'the behavior of the widget',
    (tester) async {
      layoutController = TestUILayoutController(
        wantKeepAlive: false,
      );
      widget = TestTabScreen(
        layout,
        tabController,
        key: tabBarViewKey,
      );
      await tester.pumpWidget(widget);

      // During initialization, the first tab with the
      // beginning of the listViewContent should be displayed.
      expect(find.byKey(firstTabKey), findsOneWidget);
      expect(find.byKey(secondTabKey), findsNothing);
      expect(find.byKey(firstWidgetKey), findsOneWidget);
      expect(find.byKey(lastWidgetKey), findsNothing);

      // Scroll to the end of the listViewContent.
      await tester.drag(find.byKey(listViewKey), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Last widget from the listViewContent should be displayed.
      expect(find.byKey(firstWidgetKey), findsNothing);
      expect(find.byKey(lastWidgetKey), findsOneWidget);

      // Switching between tabs(go to the second tab).
      await tester.drag(find.byKey(tabBarViewKey), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // After switching the second tab should be displayed.
      expect(find.byKey(firstTabKey), findsNothing);
      expect(find.byKey(secondTabKey), findsOneWidget);
      expect(find.byKey(firstWidgetKey), findsNothing);
      expect(find.byKey(lastWidgetKey), findsNothing);

      // Switching between tabs(back to the first tab).
      await tester.drag(find.byKey(tabBarViewKey), const Offset(500, 0));
      await tester.pumpAndSettle();

      // First widget of the listViewContent on the first tab should be
      // displayed.
      expect(find.byKey(firstTabKey), findsOneWidget);
      expect(find.byKey(secondTabKey), findsNothing);
      expect(find.byKey(firstWidgetKey), findsOneWidget);
      expect(find.byKey(lastWidgetKey), findsNothing);

      layoutController.setupWantKeepAlive(true);

      // Scroll to the end of the listViewContent.
      await tester.drag(find.byKey(listViewKey), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Last widget from the listViewContent should be displayed.
      expect(find.byKey(firstWidgetKey), findsNothing);
      expect(find.byKey(lastWidgetKey), findsOneWidget);

      // Switching between tabs(go to the second tab).
      await tester.drag(find.byKey(tabBarViewKey), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // After switching the second tab should be displayed.
      expect(find.byKey(firstTabKey), findsNothing);
      expect(find.byKey(secondTabKey), findsOneWidget);
      expect(find.byKey(firstWidgetKey), findsNothing);
      expect(find.byKey(lastWidgetKey), findsNothing);

      // Switching between tabs(back to the first tab).
      await tester.drag(find.byKey(tabBarViewKey), const Offset(500, 0));
      await tester.pumpAndSettle();

      // First widget of the listViewContent on the first tab should be
      // displayed.
      expect(find.byKey(firstTabKey), findsOneWidget);
      expect(find.byKey(secondTabKey), findsNothing);
      expect(find.byKey(firstWidgetKey), findsNothing);
      expect(find.byKey(lastWidgetKey), findsOneWidget);
    },
  );
}

final class TestLayoutControllerFactory implements LayoutControllerFactory {
  final ValueGetter<TestUILayoutController> layoutController;

  TestLayoutControllerFactory(this.layoutController);

  @override
  BaseLayoutController call() => layoutController();
}

final class TestUILayoutController extends UILayoutController
    with AutomaticKeepAliveLayoutMixin {
  bool _wantKeepAlive;

  TestUILayoutController({
    bool wantKeepAlive = true,
  }) : _wantKeepAlive = wantKeepAlive;

  @override
  bool get wantKeepAlive => _wantKeepAlive;

  void setupWantKeepAlive(bool wantKeepAlive) {
    _wantKeepAlive = wantKeepAlive;
    updateKeepAlive();
  }
}

class TestLayout extends Layout {
  final ScrollController controller;
  final List<Widget> listViewContent;

  const TestLayout(
    super.layoutControllerFactory, {
    required this.controller,
    required this.listViewContent,
    super.key,
  });

  @override
  Widget build(TestUILayoutController layoutController) {
    return Scaffold(
      body: ListView(
        key: listViewKey,
        controller: controller,
        children: listViewContent,
      ),
    );
  }
}

class TestTabScreen extends StatelessWidget {
  final Widget testWidget;
  final TabController controller;

  const TestTabScreen(
    this.testWidget,
    this.controller, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TabBarView(
        controller: controller,
        children: [
          testWidget,
          Scaffold(
            key: secondTabKey,
            body: ListView(),
          ),
        ],
      ),
    );
  }
}
