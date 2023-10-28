import 'package:flutter/animation.dart';

class _Interval {
  const _Interval(this.start, this.end) : assert(end >= start);

  final double start;
  final double end;

  bool contains(double t) => t >= start && t < end;

  double value(double t) => (t - start) / (end - start);

  @override
  String toString() => '<$start, $end>';
}

class KeyframeItem<T> {
  KeyframeItem({required this.time, required this.value});
  double time;
  T value;

  toString() => "keyframe time:${time}";
}

class KeyframeSequence<T> extends Animatable<T> {
  KeyframeSequence(List<KeyframeItem<T>> items, Duration duration)
      : assert(items.isNotEmpty) {
    _items.addAll(items);

    for (var i = 0; i < _items.length; i++) {
      KeyframeItem<T>? nextItem;
      var item = _items[i];
      final nextItemIndex = i + 1;
      if (nextItemIndex < _items.length) {
        nextItem = _items[nextItemIndex];
      }

      print(item.toString());

      if (i == 0 && item.time > 0) {
        _tweens.add(ConstantTween(item.value));
        _intervals.add(_Interval(
          0 / duration.inSeconds,
          item.time / duration.inSeconds,
        ));
      }

      if (nextItem != null) {
        _tweens.add(Tween(begin: item.value, end: nextItem.value));
        final interval = _Interval(
            item.time / duration.inSeconds, nextItem.time / duration.inSeconds);
        _intervals.add(interval);
      } else {
        _tweens.add(ConstantTween(item.value));
        _intervals.add(_Interval(item.time / duration.inSeconds,
            duration.inSeconds / duration.inSeconds));
      }
    }
    for (var i = 0; i < _tweens.length; i++) {
      print({" tween: ${_tweens[i].toString()}, interval: ${_intervals[i]} "});
    }
  }

  final List<KeyframeItem<T>> _items = <KeyframeItem<T>>[];
  final List<Tween<T>> _tweens = [];

  final List<_Interval> _intervals = <_Interval>[];

  T _evaluateAt(double t, int index) {
    final Tween<T> element = _tweens[index];
    final double tInterval = _intervals[index].value(t);

    final value = element.transform(tInterval);
    print(value);
    return value;
  }

  @override
  T transform(double t) {
    assert(t >= 0.0 && t <= 1.0);

    if (t == 1.0) {
      return _evaluateAt(t, _tweens.length - 1);
    }

    for (int index = 0; index < _tweens.length; index++) {
      if (_intervals[index].contains(t)) {
        return _evaluateAt(t, index);
      }
    }

    throw StateError(
        'TweenSequence.evaluate() could not find an interval for $t');
  }

  @override
  String toString() => 'TweenSequence(${_items.length} items)';
}
