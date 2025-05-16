part of 'counter_layout_model.dart';

final class CounterLayoutModelFactory implements LayoutModelFactory {
  final CounterStateManager _counterStateManager;
  final SnackBarWrapper _snackBarWrapper;

  CounterLayoutModelFactory({
    required CounterStateManager counterStateManager,
    required SnackBarWrapper snackBarWrapper,
  })  : _counterStateManager = counterStateManager,
        _snackBarWrapper = snackBarWrapper;

  @override
  CounterLayoutModel call() => CounterLayoutModel(
        counterStateManager: _counterStateManager,
        snackBarWrapper: _snackBarWrapper,
      );
}
