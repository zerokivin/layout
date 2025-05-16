import 'package:flutter/widgets.dart';

import '../layout_model.dart';

mixin AutomaticKeepAliveLayout on LayoutModel {
  KeepAliveHandle? _keepAliveHandle;

  /// Whether the current instance should be kept alive.
  ///
  /// Call [updateKeepAlive] whenever this getter's value changes.
  @protected
  bool get wantKeepAlive;

  /// Ensures that any [AutomaticKeepAlive] ancestors are in a good state, by
  /// firing a [KeepAliveNotification] or triggering the [KeepAliveHandle] as
  /// appropriate.
  @protected
  void updateKeepAlive() {
    if (wantKeepAlive) {
      if (_keepAliveHandle == null) {
        _ensureKeepAlive();
      }
    } else {
      if (_keepAliveHandle != null) {
        _releaseKeepAlive();
      }
    }
  }

  @override
  void init() {
    super.init();

    if (wantKeepAlive) {
      _ensureKeepAlive();
    }
  }

  @override
  void deactivate() {
    if (_keepAliveHandle != null) {
      _releaseKeepAlive();
    }

    super.deactivate();
  }

  void _ensureKeepAlive() {
    assert(_keepAliveHandle == null);
    _keepAliveHandle = KeepAliveHandle();
    KeepAliveNotification(_keepAliveHandle!).dispatch(context);
  }

  void _releaseKeepAlive() {
    _keepAliveHandle!.dispose();
    _keepAliveHandle = null;
  }
}
