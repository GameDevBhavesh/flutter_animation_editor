import 'dart:convert';
import 'dart:ui';

import 'package:animation_editor/src/extention.dart';
import 'package:animation_editor/src/extentions/list_extentions.dart';
import 'package:animation_editor/src/keyframe_sequence.dart';
import 'package:animation_editor/src/mixins/controller_manager_mixin.dart';
import 'package:animation_editor/src/models/object_track.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AnimationsCollection {
  final List<TrackedAnimation> animations;
  AnimationsCollection({
    required this.animations,
  });
  AnimationsCollection copyWith({
    List<TrackedAnimation>? animations,
  }) =>
      AnimationsCollection(
        animations: animations ?? this.animations,
      );

  factory AnimationsCollection.fromJson(Map<String, dynamic> json) =>
      AnimationsCollection(
        animations: List<TrackedAnimation>.from(
            json["animations"].map((x) => TrackedAnimation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "animations": List<dynamic>.from(animations.map((x) => x.toJson())),
      };
}

class TrackedAnimation {
  final String name;
  Duration duration;
  final Map<String, ObjectTrack> objectTracks;

  TrackedAnimation({
    required this.duration,
    required this.name,
    required this.objectTracks,
  });

  TrackedAnimation copyWith({
    String? name,
    Duration? duration,
    Map<String, ObjectTrack>? objectTracks,
  }) =>
      TrackedAnimation(
          name: name ?? this.name,
          objectTracks: objectTracks ?? this.objectTracks,
          duration: duration ?? this.duration);

  factory TrackedAnimation.fromJson(Map<String, dynamic> json) =>
      TrackedAnimation(
          name: json["name"],
          duration: Duration(seconds: json["duration"]["seconds"].toDouble()),
          objectTracks: (json["objectTracks"] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, ObjectTrack.fromJson(value))));

  Map<String, dynamic> toJson() => {
        "name": name,
        "duration": {"seconds": duration.inSeconds},
        "objectTracks":
            objectTracks.map((key, value) => MapEntry(key, value.toJson())),
      };
}

class ObjectTrack {
  final String name;
  final Map<String, PropertyTrack> tracks;
  bool isCollapsed;
  ObjectTrack({
    required this.name,
    required this.isCollapsed,
    required this.tracks,
  });

  ObjectTrack copyWith({
    String? name,
    bool? isCollapsed,
    Map<String, PropertyTrack>? tracks,
  }) =>
      ObjectTrack(
        name: name ?? this.name,
        isCollapsed: isCollapsed ?? this.isCollapsed,
        tracks: tracks ?? this.tracks,
      );

  factory ObjectTrack.fromJson(Map<String, dynamic> json) => ObjectTrack(
        name: json["name"],
        isCollapsed: json["isCollapsed"],
        tracks: (json["tracks"] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, PropertyTrack.fromJson(value))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "isCollapsed": isCollapsed,
        "tracks": tracks.map((key, value) => MapEntry(key, value.toJson())),
      };
}

class PropertyTrack {
  final String name;
  final String group;
  final String dataType;

  final List<Keyframe> keyframes;

  PropertyTrack({
    required this.name,
    required this.group,
    required this.dataType,
    required this.keyframes,
  });

  PropertyTrack copyWith({
    String? name,
    String? group,
    String? dataType,
    List<Keyframe>? keyframes,
  }) =>
      PropertyTrack(
        name: name ?? this.name,
        group: group ?? this.group,
        dataType: dataType ?? this.dataType,
        keyframes: keyframes ?? this.keyframes,
      );

  factory PropertyTrack.fromJson(Map<String, dynamic> json) => PropertyTrack(
        name: json["name"],
        group: json["group"],
        dataType: json["dataType"],
        keyframes: List<Keyframe>.from(
            json["keyframes"].map((x) => Keyframe.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "group": group,
        "dataType": dataType,
        "keyframes": List<dynamic>.from(keyframes.map((x) => x.toJson())),
      };
}

extension KeyframeCalculation on Keyframe {
  Keyframe operator -(Keyframe other) => Keyframe(
      objectKey: objectKey,
      time: time - other.time,
      value: value - value,
      trackKey: trackKey);
}

class Keyframe {
  double time;
  dynamic value;
  final String trackKey;
  final String objectKey;

  Keyframe(
      {required this.time,
      required this.value,
      required this.objectKey,
      required this.trackKey});

  @override
  bool operator ==(other) {
    return time == (other as dynamic).time;
  }

  Keyframe copyWith({
    double? time,
    Map<String, dynamic>? value,
    String? trackKey,
    String? objectKey,
  }) =>
      Keyframe(
          time: time ?? this.time,
          value: value ?? this.value,
          objectKey: objectKey ?? this.objectKey,
          trackKey: trackKey ?? this.trackKey);

  factory Keyframe.fromJson(
    Map<String, dynamic> json,
  ) =>
      Keyframe(
        time: json["time"]?.toDouble(),
        value: json["value"],
        objectKey: json["objectKey"],
        trackKey: json["trackKey"],
      );

  Map<String, dynamic> toJson() => {
        "time": time,
        "value": value,
        "objectKey": objectKey,
        "trackKey": trackKey,
      };
  @override
  int get hashCode => super.hashCode;
}

class Vector2 {
  const Vector2(this.x, this.y);
  final double x;
  final double y;

  operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  operator -() => Vector2(-x, -y);
  Vector2 operator *(double operand) => Vector2(x * operand, y * operand);
  Vector2 operator /(double operand) => Vector2(x / operand, y / operand);

  toJson() => {"x": x, "y": y};
  factory Vector2.fromJson(Map<String, dynamic> json) =>
      Vector2(json["x"].toDouble(), json["y"].toDouble());
}

class AnimationEditorContext {
  AnimationEditorContext(
      {required this.leftPanelWidth,
      required this.multiSelect,
      required this.pixelPerSeconds,
      required this.time,
      required this.zoomSpeed,
      this.selected = const [],
      required this.animationController});

  double pixelPerSeconds = 100;
  double zoomSpeed = .2;
  bool multiSelect = false;
  double leftPanelWidth = 300;
  double time = 0;
  List<Keyframe> selected;
  AnimationController animationController;
}

class PropertyTrackController extends ChangeNotifier {
  PropertyTrackController(this.track, this.context) {
    createAnimation();
  }
  final AnimationEditorContext context;
  Animation<dynamic>? _animation;
  final PropertyTrack track;

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
    keyframe.time =
        snapToSecond(keyframe.time + (delta / context.pixelPerSeconds))
            .clamp(0, double.infinity);
    // keyframeUpdateNotifier.notifyListeners();
  }

  addKeyframe(Keyframe frame) {
    track.keyframes.add(frame);
    notifyListeners();
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
    _animation = KeyframeSequence(
            track.keyframes
                .map((e) => KeyframeItem(time: e.time, value: e.value))
                .toList(),
            context.animationController.duration!)
        .animate(context.animationController);
    notifyListeners();
  }

  Animation<dynamic>? getAnimation() {
    return _animation;
  }
}

class ObjectTrackController extends ChangeNotifier
    with MultiControllerManagerMixin<PropertyTrackController> {
  ObjectTrackController(this.track, this.context) {
    for (final propertyTrack in track.tracks.entries) {
      addController(propertyTrack.key,
          PropertyTrackController(propertyTrack.value, context));
    }
  }
  final AnimationEditorContext context;
  final ObjectTrack track;

  toggleCollapse({bool? toggle}) {
    if (toggle != null) {
      track.isCollapsed = toggle;
    } else {
      track.isCollapsed = !track.isCollapsed;
    }
    notifyListeners();
  }
}

class TrackedAnimationController extends ChangeNotifier
    with MultiControllerManagerMixin<ObjectTrackController> {
  TrackedAnimationController(this.trackedAnimation, this.vsync) {
    for (final objTrack in trackedAnimation.objectTracks.entries) {
      addController(
          objTrack.key, ObjectTrackController(objTrack.value, context));
    }
  }

  TrackedAnimation trackedAnimation;

  final SingleTickerProviderStateMixin vsync;
  //data
  Map<String, PropertyTrack>? _defaultTracks;

  late AnimationEditorContext context = AnimationEditorContext(
      time: 0,
      leftPanelWidth: 200,
      multiSelect: false,
      pixelPerSeconds: 100,
      zoomSpeed: .2,
      selected: [],
      animationController: AnimationController(
          vsync: vsync, duration: trackedAnimation.duration));

  //modifiers
  double pixelPerSeconds = 100;
  double zoomSpeed = .2;
  bool multiSelect = false;
  double leftPanelWidth = 300;
  //variables
  double time = 0;
  String playType = "oneShot";
  final List<Keyframe> selectedKeyframes = [];

  //PLAYBACKS
  playPause() {
    if (context.animationController.isAnimating) {
      pause();
    } else {
      if (playType == "oneShot") {
        playForward(from: 0);
      } else if (playType == "loop") {
        context.animationController.loop();
      } else if (playType == "pingPong") {
        context.animationController.loop(reverse: true);
      }
    }
    notifyListeners();
  }

  playForward({double? from}) {
    context.animationController.forward(from: from);
    notifyListeners();
  }

  pause() {
    context.animationController.stop();
    notifyListeners();
  }

  changeDuration(Duration duration) {
    trackedAnimation.duration = duration;
    context.animationController.duration = duration;
    notifyListeners();
  }

  changePlayhead(DragUpdateDetails details) {
    if (context.animationController.isAnimating) {
      context.animationController.stop();
    }
    context.time =
        snapToSecond(details.localPosition.dx / context.pixelPerSeconds)
            .clamp(0, double.infinity);
    context.animationController.animateTo(
        time / context.animationController.duration!.inSeconds,
        duration: const Duration(milliseconds: 0),
        curve: Curves.linear);
  }

  addKeyframe(
    String objectTrackKey,
    String propertyTrackKey,
    Keyframe keyframe,
  ) {
    readController(objectTrackKey)
        ?.readController(propertyTrackKey)!
        .addKeyframe(keyframe);
  }

  setDefaultTracks(Map<String, PropertyTrack> defaultTracks) {
    _defaultTracks = defaultTracks;
  }

  addObjectTrack(String key, String name) {
    final track = trackedAnimation.objectTracks.putIfAbsent(
      key,
      () {
        return ObjectTrack(
            isCollapsed: false, name: name, tracks: _defaultTracks ?? {});
      },
    );
    addController(key, ObjectTrackController(track, context));
    notifyListeners();
  }

  deleteObjectTrack(String key) {
    trackedAnimation.objectTracks.remove(key);
    deleteController(key);
    notifyListeners();
  }

  initAnimatorEvents() {
    context.animationController.addListener(() {
      time = context.animationController.duration!.inSeconds *
          context.animationController.value;
    });
    context.animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        notifyListeners();
      }
    });
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

  moveSelectedKeyframes(DragUpdateDetails details) {
    for (var keyframe in selectedKeyframes) {
      moveKeyframe(keyframe, details.delta.dx);
    }
    final totalObjectTracks =
        selectedKeyframes.union((element) => element.objectKey);
    for (var element in totalObjectTracks) {
      readController(element.objectKey)?.notifyListeners();
    }
  }

  moveUnionKeyframes(
      ObjectTrack objectTrack, double time, DragUpdateDetails details) {
    for (var track in objectTrack.tracks.entries) {
      for (var keyframe in track.value.keyframes) {
        if (keyframe.time == time) {
          moveKeyframe(keyframe, details.delta.dx);
        }
      }
    }
    // keyframeUpdateNotifier.notifyListeners();
  }

  toggleTrack(String key, {bool? toggle}) {
    readController(key)?.toggleCollapse(toggle: toggle);
  }

  moveKeyframe(Keyframe keyframe, double delta) {
    keyframe.time = snapToSecond(keyframe.time + (delta / pixelPerSeconds))
        .clamp(0, double.infinity);
    // keyframeUpdateNotifier.notifyListeners();
  }

  onKeyframeSelect(Keyframe key) {
    if (!multiSelect) selectedKeyframes.clear();
    selectedKeyframes.add(key);
    keyframeUpdateNotifier.notifyListeners();
  }

  exportJson() {
    final json = jsonDecode(trackedAnimation.toJson().toString());
    return json;
  }

  @override
  void dispose() {
    context.animationController.dispose();
    disposeControllers();
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

  // editSelectedKeyframeValue(String valueKey, dynamic value) {
  //   if (selectedKeyframes.isNotEmpty) {
  //     selectedKeyframes.last.propertyValue[valueKey] = value;
  //   }
  //   keyframeUpdateNotifier.notifyListeners();
  // }

  onKeyframeStart(Keyframe keyframe, DragStartDetails details) {}

  onKeyframeMove(Keyframe keyframe, DragUpdateDetails details) {
    if (selectedKeyframes.length > 1) {
      moveSelectedKeyframes(details);
      return;
    }
    moveKeyframe(keyframe, details.delta.dx);
    // keyframeUpdateNotifier.notifyListeners();
  }
}
