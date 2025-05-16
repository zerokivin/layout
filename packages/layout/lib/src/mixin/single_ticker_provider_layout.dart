import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../layout_model.dart';

mixin SingleTickerProviderLayout on LayoutModel implements TickerProvider {
  Ticker? _ticker;
  ValueListenable<bool>? _tickerModeNotifier;

  @override
  Ticker createTicker(TickerCallback onTick) {
    assert(() {
      if (_ticker == null) {
        return true;
      }
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          '$runtimeType is a SingleTickerProviderLayout but multiple tickers were created.',
        ),
        ErrorDescription(
          'A SingleTickerProviderLayout can only be used as a TickerProvider once.',
        ),
        ErrorHint(
          'If a LayoutModel is used for multiple AnimationController objects, or if it is passed to other '
          'objects and those objects might use it more than one time in total, then instead of '
          'mixing in a SingleTickerProviderLayout, use a regular TickerProviderLayout.',
        ),
      ]);
    }());

    final ticker = _ticker = Ticker(
      onTick,
      debugLabel: kDebugMode ? 'created by ${describeIdentity(this)}' : null,
    );

    _updateTickerModeNotifier();
    _updateTicker(); // Sets _ticker.mute correctly.

    return ticker;
  }

  @override
  void activate() {
    super.activate();
    // We may have a new TickerMode ancestor.
    _updateTickerModeNotifier();
    _updateTicker();
  }

  @override
  void dispose() {
    assert(() {
      if (_ticker == null || !_ticker!.isActive) {
        return true;
      }
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('$this was disposed with an active Ticker.'),
        ErrorDescription(
          '$runtimeType created a Ticker via its SingleTickerProviderLayout, but at the time '
          'dispose() was called on the mixin, that Ticker was still active. The Ticker must '
          'be disposed before calling super.dispose().',
        ),
        ErrorHint(
          'Tickers used by AnimationControllers '
          'should be disposed by calling dispose() on the AnimationController itself. '
          'Otherwise, the ticker will leak.',
        ),
        _ticker!.describeForError('The offending ticker was'),
      ]);
    }());

    _tickerModeNotifier?.removeListener(_updateTicker);
    _tickerModeNotifier = null;

    super.dispose();
  }

  void _updateTicker() => _ticker?.muted = !_tickerModeNotifier!.value;

  void _updateTickerModeNotifier() {
    final newNotifier = TickerMode.getNotifier(context);
    if (newNotifier == _tickerModeNotifier) {
      return;
    }

    _tickerModeNotifier?.removeListener(_updateTicker);
    newNotifier.addListener(_updateTicker);
    _tickerModeNotifier = newNotifier;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(
      DiagnosticsProperty<Ticker>('ticker', _ticker,
          description: switch ((_ticker?.isActive, _ticker?.muted)) {
            (true, true) => 'active but muted',
            (true, _) => 'active',
            (false, true) => 'inactive and muted',
            (false, _) => 'inactive',
            (null, _) => null,
          },
          showSeparator: false,
          defaultValue: null),
    );
  }
}
