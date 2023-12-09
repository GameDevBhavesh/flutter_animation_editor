import 'package:flutter/widgets.dart';

extension AnimationControllerLoopExtensions on AnimationController {
  TickerFuture loop({
    int? count,
    bool reverse = false,
    double? min,
    double? max,
    Duration? period,
  }) {
    assert(count == null || count >= 0);
    assert(period != null || duration != null);

    min ??= lowerBound;
    max ??= upperBound;
    period ??= duration;

    if (count == 0) return animateTo(min, duration: Duration.zero);

    final tickerFuture = repeat(
      min: min,
      max: max,
      reverse: reverse,
      period: period,
    );

    if (count != null) {
      // timeout ~1 tick before it should complete (@120hz):
      int t = period!.inMilliseconds * count - 8;
      tickerFuture.timeout(Duration(milliseconds: t), onTimeout: () async {
        if (isAnimating) animateTo(reverse && count.isEven ? min! : max!);
      });
    }

    return tickerFuture;
  }
}

extension AnimHelp on Animation<dynamic>? {
  T valueOrDefault<T>(T val) {
    if (this != null) {
      return this!.value!.runtimeType == int
          ? this!.value.toDouble()
          : this!.value as T;
    }
    return val;
  }
}
