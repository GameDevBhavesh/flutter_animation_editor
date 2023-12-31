import 'dart:ui';
import 'package:animation_editor/animation_editor/property_animators/animator.dart';
import 'package:flutter/widgets.dart';
import 'package:state_managment/state_magment.dart';
import '../animation/keyframe_sequence.dart';
import '../models/models.dart';
import '../extentions/duration_extentions.dart';

import 'tracked_anim_controller.dart';

class PropertyTrackController extends BaseController {
  PropertyTrackController(this.track, this.key, this.context,
      {this.inspectorBuilder}) {
    createAnimation();
  }
  final AnimationEditorContext context;
  Animation<dynamic>? _animation;
  final PropertyTrack track;
  final String key;
  final ChangeNotifier keyframesNotifer = ChangeNotifier();
  final ChangeNotifier onAnimationChange = ChangeNotifier();
  final Widget Function(PropertyTrackController contol)? inspectorBuilder;
  bool animate = true;

  setAnimate(bool val) {
    // animate = val;
    // notifyListeners();
  }

  double snapToSecond(double a) {
    const double tolerance = 0.1; // Adjust this tolerance as needed

    double roundedValue = a.roundToDouble();
    double diff = (a - roundedValue).abs();

    if (diff <= tolerance) {
      return roundedValue;
    } else {
      return a;
    }
  }

  moveKeyframe(Keyframe keyframe, double delta) {
    keyframe.time = keyframe.time + delta / context.pixelPerSeconds;
    // snapToSecond(keyframe.time + (delta / context.pixelPerSeconds))
    //     .clamp(0, double.infinity);
    keyframesNotifer.notifyListeners();
  }

  movedKeyframe(Keyframe keyframe) {
    createAnimation();
  }

  selectKeyframe(Keyframe keyframe) {
    context.selected.add(keyframe);
    notifyListeners();
  }

  addRemoveCurrentKeyframe({dynamic? value, Type? dataType}) {
    for (var element in track.keyframes) {
      if (element.time == context.time) {
        removeKeyframe(element);
        return;
      }
    }
    addCurrentKeyframe();
  }

  addCurrentKeyframe({dynamic? value, Type? dataType}) {
    final anim = getAnimation();
    if (anim != null) {
      addKeyframe(Keyframe(
          curve: null,
          time: context.time,
          value: value ?? anim.value,
          objectId: track.objectTrackId,
          trackId: key));
    }
    createAnimation();
  }

  addKeyframe(Keyframe frame) {
    track.keyframes.add(frame);
    createAnimation();
    notifyListeners();
  }

  editKeyframeValue(dynamic value) {
    for (var element in track.keyframes) {
      if (element.time == context.time) {
        return element.value = value;
      }
    }
    notifyListeners();
  }

  Keyframe? hasKeyframeOnTime() {
    for (var element in track.keyframes) {
      if (element.time == context.time) {
        return element;
      }
    }
    return null;
    // notifyListeners();
  }

  addKeyframes(Iterable<Keyframe> frames) {
    track.keyframes.addAll(frames);
    notifyListeners();
  }

  removeKeyframe(Keyframe frame) {
    track.keyframes.remove(frame);
    notifyListeners();
  }

  removeKeyframesAtTime(double time) {
    track.keyframes.removeWhere((f) => f.time == time);
    notifyListeners();
  }

  clear(double time) {
    track.keyframes.clear();
    notifyListeners();
  }

  shortByTime() {
    track.keyframes.sort((a, b) => a.time.compareTo(b.time));
  }

  createAnimation() {
    shortByTime();
    _animation = PropertyTrackSequenceAnimation(
            track, context.animationController.duration!.toSeconds())
        .animate(context.animationController);
    onAnimationChange.notifyListeners();
  }

  Animation? getAnimation<T>() {
    return animate ? _animation : null;
  }
}
