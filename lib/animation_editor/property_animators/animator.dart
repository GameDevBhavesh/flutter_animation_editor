import 'package:animation_editor/animation_editor/property_animators/bool_property.dart';
import 'package:animation_editor/animation_editor/property_animators/matrix4_property.dart';
import 'package:animation_editor/animation_editor/property_animators/text_style_property.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart' as wid;
import 'package:vector_math/vector_math_64.dart';
import '../models/models.dart';
import 'double_property.dart';
import 'offset_property.dart';
import 'color_property.dart';
import 'property.dart';

class Animator {
  static const Map<Type, AnimationProperty> interpolators = {
    int: NumProperty(),
    double: NumProperty(),
    Offset: OffsetProperty(),
    Color: ColorProperty(),
    Matrix4: Matrix4Property(),
    wid.TextStyle: TextStyleProperty(),
    bool: BoolProperty()
  };
  static T interpolate<T>(T a, T b, double t) {
    try {
      return interpolators[T]!.lerp(a, b, t);
    } catch (e) {
      throw StateError(
          'Interpolator for type:${T.runtimeType} not found, please contact the owner of this package, issue a feature request for type:${T.runtimeType} ');
    }
  }
}

main() {
  final val = Animator.interpolate(Matrix4.translationValues(0, 0, 0),
      Matrix4.translationValues(10, 10, 10), .5);

  print(val.getTranslation().toString());
}

class DynamicTween<T> extends Animatable<T> {
  const DynamicTween(this.begin, this.end, this.curve, this.lerp);
  final T begin;
  final T end;
  final Curve curve;
  final T Function(T a, T b, double t) lerp;
  @override
  T transform(double t) {
    return lerp(begin, end, curve.transform(t));
  }
}

class PropertyTrackSequenceAnimation<T> extends Animatable<T> {
  final List<_Interval> _intervals = [];
  final List<DynamicTween> _tweens = [];
  double minTime = 0;
  double maxTime = 1;

  PropertyTrackSequenceAnimation(PropertyTrack track, double maxSeconds,
      {Map<Type, AnimationProperty>? customAnimators}) {
    final framesCount = track.keyframes.length;
    if (framesCount <= 0) return;
    final trackType = track.keyframes[0].value.runtimeType;
    customAnimators = customAnimators ?? Animator.interpolators;

    if (!customAnimators.containsKey(trackType)) {
      throw StateError(
          'No lerper found for type ${trackType.toString()} please pass mapped list of lerpers which containes lerper for type :${trackType.toString()}');
    }

    maxTime = track.keyframes[framesCount - 1].time;
    minTime = track.keyframes[0].time;

    for (var i = 0; i < framesCount; i++) {
      final frame = track.keyframes[i];
      if (i == framesCount - 1) {
        //compansate for max keyframe from max seconds value
        _intervals
            .add(_Interval(maxTime / maxSeconds, maxSeconds / maxSeconds));
        _tweens.add(DynamicTween(frame.value, frame.value,
            frame.curve ?? Curves.linear, customAnimators[trackType]!.lerp));
      } else {
        //compansate for 0-min keyfarame value
        if (i == 0 && (minTime / maxSeconds) > 0) {
          _intervals.add(_Interval(0, minTime / maxSeconds));
          _tweens.add(DynamicTween(frame.value, frame.value,
              frame.curve ?? Curves.linear, customAnimators[trackType]!.lerp));
        }

        final nextFrame = track.keyframes[i + 1];
        _intervals.add(
            _Interval(frame.time / maxSeconds, nextFrame.time / maxSeconds));
        _tweens.add(DynamicTween(frame.value, nextFrame.value,
            frame.curve ?? Curves.linear, customAnimators[trackType]!.lerp));
      }
    }
  }

  T _evaluateAt(double t, int index) {
    final DynamicTween element = _tweens[index];
    final double tInterval = _intervals[index].value(t);

    // print("${tInterval} value");
    final value = element.transform(tInterval.clamp(0, 1));
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
}

class _Interval {
  const _Interval(this.start, this.end) : assert(end >= start);

  final double start;
  final double end;

  bool contains(double t) => t >= start && t < end;

  double value(double t) {
    return (t - start) / (end - start).clamp(0, 1);
  }

  @override
  String toString() => '<$start, $end>';
}
