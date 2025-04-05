import 'package:flutter/widgets.dart';

import 'base_layout_controller.dart';
import 'layout_controller.dart';
import 'layout_controller_factory.dart';

abstract class Layout extends Widget {
  final LayoutControllerFactory layoutControllerFactory;

  const Layout(
    this.layoutControllerFactory, {
    super.key,
  });

  @override
  LayoutElement createElement() => LayoutElement(this);

  Widget build(covariant LayoutController layoutController);
}
