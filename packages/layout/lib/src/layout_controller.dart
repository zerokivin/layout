import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'base_layout_controller.dart';

abstract base class UILayoutController extends BaseLayoutController {
  @override
  CupertinoThemeData get cupertinoTheme => CupertinoTheme.of(context);

  @override
  AssetBundle get defaultAssetBundle => DefaultAssetBundle.of(context);

  @override
  DefaultTextStyle get defaultTextStyle => DefaultTextStyle.of(context);

  @override
  MediaQueryData get mediaQuery => MediaQuery.of(context);

  @override
  TextDirection get directionality => Directionality.of(context);

  @override
  ThemeData get theme => Theme.of(context);
}

abstract interface class LayoutController {
  CupertinoThemeData get cupertinoTheme;

  AssetBundle get defaultAssetBundle;

  DefaultTextStyle get defaultTextStyle;

  MediaQueryData get mediaQuery;

  TextDirection get directionality;

  ThemeData get theme;
}
