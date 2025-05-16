import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'layout.dart';

part 'layout_element.dart';

abstract class LayoutModel<T extends Layout> with Diagnosticable {
  BuildContext? _element;
  T? _layout;

  @protected
  @visibleForTesting
  T get layout {
    assert(() {
      if (_layout == null) {
        throw FlutterError('This layoutModel has been unmounted');
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
        throw FlutterError('This layoutModel has been unmounted');
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
  void didUpdateLayout(covariant T oldLayout) {}

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
  void setupTestLayout(T? layout) {
    _layout = layout;
  }

  @visibleForTesting
  void setupTestElement(BuildContext? element) {
    _element = element;
  }
}

/// Mixin that helps to prevent [NoSuchMethodError] exception when the
/// [LayoutModel] is mocked.
@visibleForTesting
mixin MockLayoutModelMixin implements LayoutModel {
  @override
  set _element(BuildContext? _) {}

  @override
  set _layout(Layout? _) {}
}
