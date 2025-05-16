import 'package:yx_scope/yx_scope.dart';
import 'package:yx_scope_counter/counter/manager/counter_state_manager.dart';
import 'package:yx_scope_counter/util/snack_bar_wrapper.dart';

import '../counter/ui/layout_model/counter_layout_model.dart';

abstract interface class AppScope {
  CounterLayoutModelFactory get counterLayoutModelFactory;
}

final class AppScopeContainer extends ScopeContainer implements AppScope {
  @override
  late final counterLayoutModelFactory = _counterLayoutModelFactoryDep.get;

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

  late final _counterLayoutModelFactoryDep = dep(
    () => CounterLayoutModelFactory(
      counterStateManager: _counterStateManagerDep.get,
      snackBarWrapper: _snackBarWrapperDep.get,
    ),
  );
}
