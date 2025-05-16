import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../layout_model.dart';

mixin TickerProviderLayout on LayoutModel implements TickerProvider {
  Set<Ticker>? _tickers;
  ValueListenable<bool>? _tickerModeNotifier;

  @override
  Ticker createTicker(TickerCallback onTick) {
    if (_tickerModeNotifier == null) {
      // Setup TickerMode notifier before we vend the first ticker.
      _updateTickerModeNotifier();
    }

    assert(_tickerModeNotifier != null);

    final result = _WidgetTicker(
      onTick,
      this,
      debugLabel: kDebugMode ? 'created by ${describeIdentity(this)}' : null,
    )..muted = !_tickerModeNotifier!.value;

    _tickers ??= <_WidgetTicker>{result};

    return result;
  }

  @override
  void activate() {
    super.activate();
    // We may have a new TickerMode ancestor, get its Notifier.
    _updateTickerModeNotifier();
    _updateTickers();
  }

  @override
  void dispose() {
    assert(() {
      if (_tickers != null) {
        for (final Ticker ticker in _tickers!) {
          if (ticker.isActive) {
            throw FlutterError.fromParts(<DiagnosticsNode>[
              ErrorSummary('$this was disposed with an active Ticker.'),
              ErrorDescription(
                '$runtimeType created a Ticker via its TickerProviderLayout, but at the time '
                'dispose() was called on the mixin, that Ticker was still active. All Tickers must '
                'be disposed before calling super.dispose().',
              ),
              ErrorHint(
                'Tickers used by AnimationControllers '
                'should be disposed by calling dispose() on the AnimationController itself. '
                'Otherwise, the ticker will leak.',
              ),
              ticker.describeForError('The offending ticker was'),
            ]);
          }
        }
      }
      return true;
    }());

    _tickerModeNotifier?.removeListener(_updateTickers);
    _tickerModeNotifier = null;

    super.dispose();
  }

  void _updateTickers() {
    if (_tickers != null) {
      final muted = !_tickerModeNotifier!.value;

      for (final ticker in _tickers ?? {}) {
        ticker.muted = muted;
      }
    }
  }

  void _updateTickerModeNotifier() {
    final newNotifier = TickerMode.getNotifier(context);
    if (newNotifier == _tickerModeNotifier) {
      return;
    }

    _tickerModeNotifier?.removeListener(_updateTickers);
    newNotifier.addListener(_updateTickers);
    _tickerModeNotifier = newNotifier;
  }

  void _removeTicker(_WidgetTicker ticker) {
    assert(_tickers != null);
    assert(_tickers!.contains(ticker));
    _tickers!.remove(ticker);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(
      DiagnosticsProperty<Set<Ticker>>(
        'tickers',
        _tickers,
        description: _tickers != null
            ? 'tracking ${_tickers!.length} ticker${_tickers!.length == 1 ? "" : "s"}'
            : null,
        defaultValue: null,
      ),
    );
  }
}

// This class should really be called _DisposingTicker or some such, but this
// class name leaks into stack traces and error messages and that name would be
// confusing. Instead we use the less precise but more anodyne "_WidgetTicker",
// which attracts less attention.
class _WidgetTicker extends Ticker {
  final TickerProviderLayout _creator;

  _WidgetTicker(
    super.onTick,
    this._creator, {
    super.debugLabel,
  });

  @override
  void dispose() {
    _creator._removeTicker(this);

    super.dispose();
  }
}
