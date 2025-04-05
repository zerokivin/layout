import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'layout.dart';
import 'layout_controller.dart';

part 'layout_element.dart';

abstract base class BaseLayoutController
    with Diagnosticable
    implements LayoutController {
  BuildContext? _element;
  Layout? _layout;

  @protected
  @visibleForTesting
  Layout get layout {
    assert(() {
      if (_layout == null) {
        throw FlutterError('This LayoutController has been unmounted');
      }

      return true;
    }());

    return _layout!;
  }

  @protected
  @visibleForTesting
  BuildContext get context {
    assert(() {
      if (_element == null) {
        throw FlutterError('This LayoutController has been unmounted');
      }

      return true;
    }());

    return _element!;
  }

  @protected
  @visibleForTesting
  bool get isMounted => _element != null;

  @protected
  @visibleForTesting
  void init() {}

  @protected
  @visibleForTesting
  void activate() {}

  @protected
  @visibleForTesting
  void didChangeDependencies() {}

  @protected
  @visibleForTesting
  void didUpdateLayout(covariant Layout oldLayout) {}

  @protected
  @visibleForTesting
  void reassemble() {}

  @protected
  @visibleForTesting
  void deactivate() {}

  @protected
  @visibleForTesting
  void dispose() {}

  @visibleForTesting
  void setupTestLayout(Layout? layout) {
    _layout = layout;
  }

  @visibleForTesting
  void setupTestElement(BuildContext? element) {
    _element = element;
  }
}

/// Mixin that helps to prevent [NoSuchMethodError] exception when the
/// [BaseLayoutController] is mocked.
@visibleForTesting
base mixin MockLayoutControllerMixin implements BaseLayoutController {
  @override
  set _element(BuildContext? _) {}

  @override
  set _layout(Layout? _) {}
}
