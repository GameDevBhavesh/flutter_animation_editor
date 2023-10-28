// import 'dart:ffi';

import 'dart:collection' as col;
import 'dart:convert';
import 'dart:ui';

import 'package:animation_editor/src/extention.dart';
import 'package:animation_editor/src/keyframe_sequence.dart';
import 'package:flutter/animation.dart' as anim;
import 'package:flutter/widgets.dart';

import 'models.dart';

extension ColorEx on String {
  Color get color {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');

    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

Map<String, Function(Map<String, dynamic> value)> valueParser = {
  "Offset": (value) {
    return Offset(value["x"].toDouble(), value["y"].toDouble());
  },
  "double": (value) {
    return value["value"].toDouble();
  },
  "Color": (value) {
    return (value["value"] as String).color;
  }
};

Map<String,
        Widget Function(String trackKey, String keyframesKey, dynamic value)>
    valueBuilder = {
  "Offset": (trackKey, key, value) {
    final offValue = value as Offset;
    return Row(
      children: [Text(offValue.dx.toString()), Text(offValue.dy.toString())],
    );
  }
};

class AnimationEditorController extends ChangeNotifier {
  AnimationEditorController(this.timelineEntity, this.vsync) {
    initAnimatorEvents();
    generateAnimationMap();
  }

  final SingleTickerProviderStateMixin vsync;
  //data
  final AnimationTimelineEntity timelineEntity;

  //controllers
  late TextEditingController timelineDurationTextController =
      TextEditingController(text: timelineEntity.duration.seconds.toString());

  late AnimationController animationController = AnimationController(
      vsync: vsync,
      duration: Duration(seconds: timelineEntity.duration.seconds));

  //Notifiers
  final ChangeNotifier keyframeSelectedNotifier = ChangeNotifier();
  final ChangeNotifier keyframeUpdateNotifier = ChangeNotifier();

  //Events Notifiers
  final ChangeNotifier onAnimationCreated = ChangeNotifier();
  final List<Keyframe> selectedKeyframes = [];

  //modifiers
  double pixelPerSeconds = 100;
  double zoomSpeed = .2;
  bool multiSelect = false;
  double leftPanelWidth = 300;

  //values
  double time = 2;

  final Map<String, Map<String, Animation<dynamic>>> _animationMap = {};

  /// Example final posAnim = Animation<double> =  controller.toAnimationMap()["trackid"]["position"]
  Map<String, Map<String, Animation<dynamic>>> get animationMap =>
      _animationMap;

  Animation<dynamic>? getAnimation(String trackKey, String keyframesKey) {
    if (!_animationMap.containsKey(trackKey)) {
      return null;
    }
    if (!_animationMap[trackKey]!.containsKey(keyframesKey)) {
      return null;
    }
    return _animationMap[trackKey]![keyframesKey]!;
  }

  bool hasKeyframes(String trackKey, String keyframesKey) {
    if (!timelineEntity.tracks.containsKey(trackKey)) {
      return false;
    }
    if (!timelineEntity.tracks[trackKey]!.keyframes.containsKey(keyframesKey)) {
      return false;
    }
    return true;
  }

  KeyframeItem parseKeyframe(Keyframe frame) {
    bool parserExist = valueParser.containsKey(frame.propertyType);

    if (parserExist) {
      final value = valueParser[frame.propertyType]!(frame.propertyValue);
      return KeyframeItem(time: frame.time, value: value);
    }

    return KeyframeItem<double>(
        time: frame.time, value: frame.propertyValue["value"].toDouble());
  }

  generateAnimationMap() {
    print("create animation");
    for (final trackKey in timelineEntity.tracks.keys) {
      _animationMap.putIfAbsent(trackKey, () => {});
      for (final keyframesKey
          in timelineEntity!.tracks[trackKey]!.keyframes.keys) {
        generateTrackAnimationMap(trackKey, keyframesKey);
      }
    }
    onAnimationCreated.notifyListeners();
    notifyListeners();
  }

  generateTrackAnimationMap(String trackKey, String keyframesKey) {
    print("generateTrackAnimationMap ");
    final trackExists = timelineEntity.tracks.containsKey(trackKey);
    if (trackExists) {
      final keyframesExists =
          timelineEntity.tracks[trackKey]!.keyframes.containsKey(keyframesKey);
      if (keyframesExists) {
        timelineEntity.tracks[trackKey]!.keyframes[keyframesKey]!
            .sort((a, b) => a.time.compareTo(b.time));

        final animationExist =
            _animationMap[trackKey]!.containsKey(keyframesKey);

        if (animationExist) {
          _animationMap[trackKey]![keyframesKey] = KeyframeSequence(
            timelineEntity.tracks[trackKey]!.keyframes[keyframesKey]!
                .map((e) => parseKeyframe(e))
                .toList(),
            animationController.duration!,
          ).animate(animationController);
        } else {
          _animationMap[trackKey]!.putIfAbsent(keyframesKey, () {
            return KeyframeSequence(
              timelineEntity.tracks[trackKey]!.keyframes[keyframesKey]!
                  .map((e) => parseKeyframe(e))
                  .toList(),
              animationController.duration!,
            ).animate(animationController);
          });
        }
      }
    }
    onAnimationCreated.notifyListeners();
  }

  initAnimatorEvents() {
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

      generateAnimationMap();
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

  moveSelectedKeyframes(DragUpdateDetails details) {
    for (var keyframe in selectedKeyframes) {
      moveKeyframe(keyframe, details.delta.dx);
    }
    keyframeUpdateNotifier.notifyListeners();
  }

  moveUnionKeyframes(Track track, double time, DragUpdateDetails details) {
    for (var keyframes in track.keyframes.entries) {
      for (var keyframe in keyframes.value) {
        if (keyframe.time == time) {
          moveKeyframe(keyframe, details.delta.dx);
        }
      }
    }
    keyframeUpdateNotifier.notifyListeners();
  }

  toggleTrack(Track track, {bool? toogle}) {
    if (toogle != null) {
      track.isCollapsed = toogle;
    } else {
      track.isCollapsed = !track.isCollapsed;
    }
    keyframeUpdateNotifier.notifyListeners();
  }

  moveKeyframe(Keyframe keyframe, double delta) {
    keyframe.time =
        roundToNearestSecond(keyframe.time + (delta / pixelPerSeconds))
            .clamp(0, double.infinity);
    keyframeUpdateNotifier.notifyListeners();
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
    animationController.dispose();
    super.dispose();
  }

  // UI Actions
  onPanelSplit(DragUpdateDetails details) {
    leftPanelWidth = (leftPanelWidth + details.delta.dx).clamp(200, 600);
    notifyListeners();
  }

  onZoomScroll(double value) {
    pixelPerSeconds = lerpDouble(
        pixelPerSeconds, (pixelPerSeconds + value).clamp(10, 1000), zoomSpeed)!;
    notifyListeners();
  }

  editSelectedKeyframeValue(String valueKey, dynamic value) {
    if (selectedKeyframes.isNotEmpty) {
      selectedKeyframes.last.propertyValue[valueKey] = value;
    }
    keyframeUpdateNotifier.notifyListeners();
  }

  addKeyframe(
    String trackKey,
    String keyframesKey,
    Keyframe keyframe,
  ) {
    final trackExist = timelineEntity.tracks.containsKey(trackKey);
    final keyframesExist =
        timelineEntity.tracks[trackKey]!.keyframes.containsKey(keyframesKey);

    if (!trackExist) {
      timelineEntity.tracks
          .putIfAbsent(trackKey, () => Track(name: trackKey, keyframes: {}));
    }

    if (!keyframesExist) {
      timelineEntity.tracks[trackKey]!.keyframes
          .putIfAbsent(keyframesKey, () => [keyframe]);
    } else {
      timelineEntity.tracks[trackKey]!.keyframes[keyframesKey]!.add(keyframe);
    }
    generateTrackAnimationMap(trackKey, keyframesKey);
    notifyListeners();
  }

  onKeyframeStart(Keyframe keyframe, DragStartDetails details) {}

  onKeyframeMove(Keyframe keyframe, DragUpdateDetails details) {
    if (selectedKeyframes.length > 1) {
      moveSelectedKeyframes(details);
      return;
    }
    moveKeyframe(keyframe, details.delta.dx);
    keyframeUpdateNotifier.notifyListeners();
  }
}
