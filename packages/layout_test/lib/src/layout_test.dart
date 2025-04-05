// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:layout/layout.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';

/// Testing function for test LayoutController.
/// [description] - description of test.
/// [setupLayoutController] - function should return LayoutController that will be test.
/// [testFunction] - function that test LayoutController.
/// [skip] - should skip the test. If passed a String or `true`, the test is
/// skipped. If it's a String, it should explain why the test is skipped;
/// this reason will be printed instead of running the test.
///
/// If [timeout] is passed, it's used to modify or replace the default timeout
/// of 30 seconds. Timeout modifications take precedence in suite-group-test
/// order, so [timeout] will also modify any timeouts set on the group or suite.
///
/// The description will be added to the descriptions of any surrounding
/// [group]s. If [testOn] is passed, it's parsed as a [platform selector][]; the
/// test will only be run on matching platforms.
///
/// If [tags] is passed, it declares user-defined tags that are applied to the
/// test. These tags can be used to select or skip the test on the command line,
/// or to do bulk test configuration. All tags should be declared in the
/// [package configuration file][configuring tags]. The parameter can be an
/// [Iterable] of tag names, or a [String] representing a single tag.
///
/// [onPlatform] allows tests to be configured on a platform-by-platform
/// basis. It's a map from strings that are parsed as PlatformSelectors to
/// annotation classes: [Timeout], [Skip], or lists of those. These
/// annotations apply only on the given platforms.
///
/// If [retry] is passed, the test will be retried the provided number of times
/// before being marked as a failure.
@isTest
void testLayoutController<T extends BaseLayoutController>(
  String description,
  T Function() setupLayoutController,
  FutureOr<void> Function(
    T layoutController,
    LayoutControllerTester<T> tester,
    MockedContext context,
  ) testFunction, {
  String? testOn,
  Timeout? timeout,
  Object? skip,
  Object? tags,
  Map<String, Object?>? onPlatform,
  int? retry,
}) {
  setUp(() {
    registerFallbackValue(MockedContext());
  });

  test(
    description,
    () async {
      final layoutController = setupLayoutController();
      final element = _LayoutTestableElement<T>(layoutController);

      when(() => element.mounted).thenReturn(true);

      await testFunction(layoutController, element, element);
    },
    testOn: testOn,
    timeout: timeout,
    skip: skip,
    tags: tags,
    onPlatform: onPlatform,
    retry: retry,
  );
}

/// Interface for emulating BuildContext behaviour.
class MockedContext extends Mock implements BuildContext {}

/// Interface for controlling LayoutController's stage during tests.
/// Every method in this interface represents possible changes
/// with LayoutController and allows to emulate this happened.
///
/// For additional information check the lifecycle of the [BaseLayoutController].
abstract class LayoutControllerTester<T extends BaseLayoutController> {
  /// Emulates initializing LayoutController to work.
  ///
  /// Represents processes happen with LayoutController when it is inseted
  /// into the tree, before the first build of the subtree.
  void init({covariant Layout? initLayout});

  /// Emulates changing a layout instance associated
  /// with the according LayoutElement.
  void update(covariant Layout newLayout);

  /// Emulates changing of dependencies LayoutController has subscribed
  /// by BuildContext.
  void didChangeDependencies();

  /// Emulates the transition from the "inactive"
  /// to the "active" lifecycle state.
  ///
  /// In real work happens when the LayoutController is reinserted into
  /// the tree after having been removed via [deactivate].
  void activate();

  /// Emulates the transition from the "active"
  /// to the "inactive" lifecycle state.
  ///
  /// In real work happens when the LayoutController is removed from the tree.
  void deactivate();

  /// Emulates the transition from the "inactive"
  /// to the "defunct" lifecycle state.
  ///
  /// In real work happens when the LayoutController is removed from the
  /// tree permanently.
  /// See also:
  /// [BaseLayoutController.dispose];
  void unmount();
}

class _LayoutTestableElement<T extends BaseLayoutController>
    extends MockedContext
    with Diagnosticable
    implements LayoutControllerTester<T> {
  final T _layoutController;

  _LayoutTestableElement(
    this._layoutController,
  );

  @override
  void init({Layout? initLayout}) {
    _layoutController
      ..setupTestElement(this)
      ..setupTestLayout(initLayout)
      ..init()
      ..didChangeDependencies();
  }

  @override
  void update(Layout newLayout) {
    final oldLayout = _layoutController.layout;
    _layoutController
      ..setupTestLayout(newLayout)
      ..didUpdateLayout(oldLayout);
  }

  @override
  void didChangeDependencies() {
    _layoutController.didChangeDependencies();
  }

  @override
  void activate() {
    _layoutController.activate();
  }

  @override
  void deactivate() {
    _layoutController.deactivate();
  }

  @override
  void unmount() {
    _layoutController
      ..dispose()
      ..setupTestElement(null)
      ..setupTestLayout(null);
  }
}
