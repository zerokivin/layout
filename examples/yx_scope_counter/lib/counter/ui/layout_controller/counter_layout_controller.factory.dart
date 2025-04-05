part of 'counter_layout_controller.dart';

final class CounterLayoutControllerFactory implements LayoutControllerFactory {
  final CounterStateManager _counterStateManager;
  final SnackBarWrapper _snackBarWrapper;

  CounterLayoutControllerFactory({
    required CounterStateManager counterStateManager,
    required SnackBarWrapper snackBarWrapper,
  })  : _counterStateManager = counterStateManager,
        _snackBarWrapper = snackBarWrapper;

  @override
  BaseLayoutController call() => CounterUILayoutController(
        counterStateManager: _counterStateManager,
        snackBarWrapper: _snackBarWrapper,
      );
}
