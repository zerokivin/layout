import 'package:flutter/widgets.dart';

import 'layout_model.dart';
import 'layout_model_factory.dart';

abstract class Layout extends Widget {
  final LayoutModelFactory layoutModelFactory;

  const Layout(
    this.layoutModelFactory, {
    super.key,
  });

  @override
  LayoutElement createElement() => LayoutElement(this);

  Widget build(covariant LayoutModel layoutModel);
}
