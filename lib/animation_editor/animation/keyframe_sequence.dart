import 'package:flutter/animation.dart';

extension ColorExtensions on Color {
  Color clamp() {
    return Color.fromARGB(
      alpha.clamp(0, 255),
      red.clamp(0, 255),
      green.clamp(0, 255),
      blue.clamp(0, 255),
    );
  }

  Color operator -(Color other) {
    return Color.fromARGB(
      (this.alpha - other.alpha).clamp(0, 255),
      (this.red - other.red).clamp(0, 255),
      (this.green - other.green).clamp(0, 255),
      (this.blue - other.blue).clamp(0, 255),
    );
  }

  Color operator +(Color other) {
    return Color.fromARGB(
      (this.alpha + other.alpha).clamp(0, 255),
      (this.red + other.red).clamp(0, 255),
      (this.green + other.green).clamp(0, 255),
      (this.blue + other.blue).clamp(0, 255),
    );
  }

  Color operator *(double factor) {
    return Color.fromARGB(
      (this.alpha * factor).clamp(0, 255).round(),
      (this.red * factor).clamp(0, 255).round(),
      (this.green * factor).clamp(0, 255).round(),
      (this.blue * factor).clamp(0, 255).round(),
    );
  }
}

class _Interval {
  const _Interval(this.start, this.end, this.curve) : assert(end >= start);
  final Curve curve;
  final double start;
  final double end;

  bool contains(double t) => t >= start && t < end;

  double value(double t) {
    // print(t);
    return curve.transform((t - start) / (end - start));
  }

  @override
  String toString() => '<$start, $end>';
}

class KeyframeItem<T> {
  KeyframeItem(
      {required this.time, required this.value, this.curve = Curves.easeIn});
  double time;
  T value;
  Curve? curve;

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

      if (i == 0 && item.time > 0) {
        _tweens.add(ConstantTween(item.value));
        _intervals.add(_Interval(0 / duration.inSeconds,
            item.time / duration.inSeconds, Curves.linear));
      }
      if (nextItem != null) {
        if (item.value.runtimeType == Color) {
          _tweens.add(ColorTween(
              begin: item.value as Color,
              end: nextItem.value as Color) as Tween<T>);
        } else {
          _tweens.add(Tween(begin: item.value, end: nextItem.value));
        }
        final interval = _Interval(item.time / duration.inSeconds,
            nextItem.time / duration.inSeconds, item.curve!);
        _intervals.add(interval);
      } else {
        if (item.value.runtimeType == Color) {
          _tweens.add(
              ColorTween(begin: item.value as Color, end: item.value as Color)
                  as Tween<T>);
        } else {
          _tweens.add(ConstantTween(item.value));
        }
        _intervals.add(_Interval(item.time / duration.inSeconds,
            duration.inSeconds / duration.inSeconds, Curves.linear));
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

    return value;
  }

  @override
  T transform(double t) {
    assert(t >= 0.0 && t <= 1.0);

    if (t == 1.0) {
      return _evaluateAt(t, _tweens.length - 1);
    }

    for (int index = 0; index < _tweens.length; index++) {
      // print(" pos :${_intervals[index]}, t:${t}");
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
