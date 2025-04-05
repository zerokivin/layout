part of 'base_layout_controller.dart';

base class LayoutElement extends ComponentElement {
  late BaseLayoutController _layoutController;

  // private _firstBuild hack
  bool _isInitialized = false;

  LayoutElement(
    Layout super.widget,
  );

  @override
  Layout get widget => super.widget as Layout;

  @override
  Widget build() => widget.build(_layoutController);

  @override
  void update(Layout newWidget) {
    super.update(newWidget);

    final oldLayout = _layoutController.layout;
    _layoutController
      .._layout = newWidget
      ..didUpdateLayout(oldLayout);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _layoutController.didChangeDependencies();
  }

  @override
  void activate() {
    super.activate();

    _layoutController.activate();
    markNeedsBuild();
  }

  @override
  void deactivate() {
    _layoutController.deactivate();

    super.deactivate();
  }

  @override
  void unmount() {
    super.unmount();

    _layoutController
      ..dispose()
      .._element = null
      .._layout = null;
  }

  @override
  void performRebuild() {
    // private _firstBuild hack
    if (!_isInitialized) {
      _layoutController = widget.layoutControllerFactory();
      _layoutController
        .._element = this
        .._layout = widget
        ..init()
        ..didChangeDependencies();

      _isInitialized = true;
    }

    super.performRebuild();
  }

  @override
  void reassemble() {
    _layoutController.reassemble();

    super.reassemble();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(
      DiagnosticsProperty<BaseLayoutController>(
        'layout_controller',
        _layoutController,
        defaultValue: null,
      ),
    );
  }
}
