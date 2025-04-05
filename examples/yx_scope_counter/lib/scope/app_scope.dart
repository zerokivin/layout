import 'package:yx_scope/yx_scope.dart';
import 'package:yx_scope_counter/counter/manager/counter_state_manager.dart';
import 'package:yx_scope_counter/counter/ui/counter_layout_controller_factory.dart';
import 'package:yx_scope_counter/util/snack_bar_wrapper.dart';

abstract interface class AppScope {
  CounterLayoutControllerFactory get counterLayoutControllerFactory;
}

final class AppScopeContainer extends ScopeContainer implements AppScope {
  @override
  late final counterLayoutControllerFactory =
      _counterLayoutControllerFactoryDep.get;

  @override
  List<Set<AsyncDep>> get initializeQueue => [
        {
          _counterStateManagerDep,
        },
      ];

  late final _snackBarWrapperDep = dep(
    () => const SnackBarWrapper(),
  );

  late final _counterStateManagerDep = asyncDep(
    () => CounterStateManager.create(),
  );

  late final _counterLayoutControllerFactoryDep = dep(
    () => CounterLayoutControllerFactory(
      counterStateManager: _counterStateManagerDep.get,
      snackBarWrapper: _snackBarWrapperDep.get,
    ),
  );
}
