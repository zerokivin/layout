import 'package:yx_scope/yx_scope.dart';
import 'package:yx_scope_counter/scope/app_scope.dart';

final class AppScopeHolder extends ScopeHolder<AppScopeContainer> {
  @override
  AppScopeContainer createContainer() => AppScopeContainer();
}
