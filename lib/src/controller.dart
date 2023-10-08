// import 'dart:ffi';

import 'dart:collection' as col;
import 'dart:convert';
import 'dart:ui';

import 'package:animation_editor/src/extention.dart';
import 'package:flutter/animation.dart' as anim;

import 'package:flutter/widgets.dart';

import 'models.dart';

class AnimationEditorController extends ChangeNotifier {
  final SingleTickerProviderStateMixin vsync;

  //data
  final AnimationTimelineEntity timelineEntity;
  // final Map<String, Animation> timelineAnimationEntity;

  //controllers
  late TextEditingController timelineDurationTextController =
      TextEditingController(text: timelineEntity.duration.seconds.toString());
  late AnimationController animationController = AnimationController(
      vsync: vsync,
      duration: Duration(seconds: timelineEntity.duration.seconds));

  //Notifiers
  final ChangeNotifier keyframeSelectedNotifier = ChangeNotifier();
  final ChangeNotifier keyframeUpdateNotifier = ChangeNotifier();

  final List<Keyframe> selectedKeyframes = [];

  //modifiers
  double pixelPerSeconds = 100;
  double zoomSpeed = .2;
  bool multiSelect = false;
  double leftPanelWidth = 300;

  //values
  double time = 2;

  AnimationEditorController(this.timelineEntity, this.vsync) {
    animationController.addListener(() {
      time =
          animationController.duration!.inSeconds * animationController.value;
    });
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        notifyListeners();
      }
      print("$status  ${timelineEntity.playType}");
    });
  }
  setPlayType(String type) {
    timelineEntity.playType = type;
    notifyListeners();
  }

  playPause() {
    print("playPause  playing:${animationController.isAnimating}");
    if (animationController.isAnimating) {
      pause();
    } else {
      if (timelineEntity.playType == "oneShot") {
        playForward(from: 0);
      } else if (timelineEntity.playType == "loop") {
        animationController.loop();
      } else if (timelineEntity.playType == "pingPong") {
        animationController.loop(reverse: true);
      }

      // playForward();
    }
    notifyListeners();
  }

  playForward({double? from}) {
    animationController.forward(from: from);
    notifyListeners();
  }

  pause() {
    animationController.stop();
    notifyListeners();
  }

  onTimelinDurationChange(String val) {
    timelineEntity.duration = AnimDuration(seconds: int.parse(val));
    animationController.duration =
        Duration(seconds: timelineEntity.duration.seconds);
    notifyListeners();
    // MultiTween
  }

  onTimeHandleDrag(DragUpdateDetails details) {
    animationController.stop();
    time = roundToNearestSecond(details.localPosition.dx / pixelPerSeconds)
        .clamp(0, double.infinity);

    animationController.animateTo(
        time / animationController.duration!.inSeconds,
        duration: const Duration(milliseconds: 0),
        curve: Curves.linear);
  }

  double roundToNearestSecond(double a) {
    const double tolerance = 0.1; // Adjust this tolerance as needed

    double roundedValue = a.roundToDouble();
    double diff = (a - roundedValue).abs();

    if (diff <= tolerance) {
      return roundedValue;
    } else {
      return a;
    }
  }

  onPanelSplit(DragUpdateDetails details) {
    leftPanelWidth = (leftPanelWidth + details.delta.dx).clamp(200, 600);
    notifyListeners();
  }

  onZoomScroll(double value) {
    pixelPerSeconds = lerpDouble(
        pixelPerSeconds, (pixelPerSeconds + value).clamp(10, 1000), zoomSpeed)!;
    notifyListeners();
  }

  toAnimations() {
    timelineEntity.tracks.putIfAbsent(
        "sadas",
        () => Track(name: "Item44", keyframes: {
              "pos": [
                Keyframe(
                    time: 1,
                    itemId: "sadas",
                    propertyKey: "pos",
                    propertyValue: {"x": 1, "y": 2},
                    curve: "linear")
              ]
            }));
  }

  onKeyframeMove(Keyframe keyframe, DragUpdateDetails details) {
    if (selectedKeyframes.length > 1) {
      onMultipleKeyframesMove(keyframe, details);
      return;
    }
    moveKeyframe(keyframe, details.delta.dx);
    keyframeUpdateNotifier.notifyListeners();
  }

  moveKeyframe(Keyframe keyframe, double delta) {
    keyframe.time =
        roundToNearestSecond(keyframe.time + (delta / pixelPerSeconds))
            .clamp(0, double.infinity);
    keyframeUpdateNotifier.notifyListeners();
  }

  onMultipleKeyframesMove(Keyframe keyframe, DragUpdateDetails details) {
    for (var keyframe in selectedKeyframes) {
      moveKeyframe(keyframe, details.delta.dx);
    }
    keyframeUpdateNotifier.notifyListeners();
  }

  onTrackKeyframesMove(Track track, double time, DragUpdateDetails details) {
    for (var keyframes in track.keyframes.entries) {
      for (var keyframe in keyframes.value) {
        if (keyframe.time == time) {
          moveKeyframe(keyframe, details.delta.dx);
        }
      }
    }
    keyframeUpdateNotifier.notifyListeners();
  }

  onCollapseTrackToggle(Track track) {
    track.isCollapsed = !track.isCollapsed;
    keyframeUpdateNotifier.notifyListeners();
  }

  addKeyframe(double time, Keyframe keyframe) {
    // timelineEntity.keyframes.add(keyframe);
    notifyListeners();
    onKeyframeSelect(keyframe);
  }

  addTrack(String key, String name) {
    timelineEntity.tracks.putIfAbsent(
      key,
      () {
        return Track(keyframes: {}, isCollapsed: true, name: name);
      },
    );
    notifyListeners();
  }

  addKeyframes(String trackKey, String keyframesKey, List<Keyframe> keyframes) {
    if (timelineEntity.tracks.containsKey(trackKey)) {
      timelineEntity.tracks[trackKey]!.keyframes
          .putIfAbsent(keyframesKey, () => keyframes);
    }

    notifyListeners();
  }

  onKeyframeSelect(Keyframe key) {
    if (!multiSelect) selectedKeyframes.clear();

    selectedKeyframes.add(key);
    keyframeUpdateNotifier.notifyListeners();
  }

  exportJson() {
    final json = jsonDecode(timelineEntity.toJson().toString());
    print(json);
    return json;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }
}
