part of 'layout_model.dart';

base class LayoutElement extends ComponentElement {
  late LayoutModel _layoutModel;

  // private _firstBuild hack
  bool _isInitialized = false;

  LayoutElement(
    Layout super.widget,
  );

  @override
  Layout get widget => super.widget as Layout;

  @override
  Widget build() => widget.build(_layoutModel);

  @override
  void update(Layout newWidget) {
    super.update(newWidget);

    final oldLayout = _layoutModel.layout;
    _layoutModel
      .._layout = newWidget
      ..didUpdateLayout(oldLayout);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _layoutModel.didChangeDependencies();
  }

  @override
  void activate() {
    super.activate();

    _layoutModel.activate();
    markNeedsBuild();
  }

  @override
  void deactivate() {
    _layoutModel.deactivate();

    super.deactivate();
  }

  @override
  void unmount() {
    super.unmount();

    _layoutModel
      ..dispose()
      .._element = null
      .._layout = null;
  }

  @override
  void performRebuild() {
    // private _firstBuild hack
    if (!_isInitialized) {
      _layoutModel = widget.layoutModelFactory();
      _layoutModel
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
    _layoutModel.reassemble();

    super.reassemble();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(
      DiagnosticsProperty<LayoutModel>(
        'layout_model',
        _layoutModel,
        defaultValue: null,
      ),
    );
  }
}
