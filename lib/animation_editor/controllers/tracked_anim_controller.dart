import 'dart:ui';

import 'package:animation_editor/animation_editor/controllers/property_track_controller.dart';
// import 'package:animation_editor/src/controller.dart';
import 'package:animation_editor/animation_editor/extentions/anim_extention.dart';
import 'package:animation_editor/animation_editor/extentions/list_extentions.dart';
import 'package:flutter/material.dart';
import 'package:state_managment/state_magment.dart';

import '../models/models.dart';
import '../property_animators/double_property.dart';
import 'object_track_controller.dart';

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

  double get handlePos => (time * pixelPerSeconds)
      .clamp(0, animationController.duration!.inSeconds * pixelPerSeconds)
      .toDouble();
}

class TrackedAnimationController extends BaseController
    with MultiControllerManagerMixin<ObjectTrackController> {
  TrackedAnimationController(
    this.trackedAnimation,
    this.vsync,
  ) {
    initAnimatorEvents();
    for (final objTrack in trackedAnimation.objectTracks.entries) {
      addChildController(
          objTrack.key,
          ObjectTrackController(
            objTrack.value,
            objTrack.key,
            context,
          ));
    }
  }

  //controlers
  late TextEditingController durationTextController = TextEditingController(
      text: trackedAnimation.duration.inSeconds.toString());

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
  String playMode = "oneShot";
  final List<Keyframe> selectedKeyframes = [];

  bool animate = true;
  setAnimate(bool val) {
    animate = val;
    readChildControllers().forEach(
      (element) {
        element.setAnimate(animate);
      },
    );
    notifyListeners();
  }

  initAnimatorEvents() {
    context.animationController.addListener(() {
      context.time = (context.animationController.duration!.inSeconds *
          context.animationController.value);

      if (context.animationController.isAnimating && !animate) {
        setAnimate(true);
      } else if (!context.animationController.isAnimating && animate) {
        setAnimate(false);
      }
    });
    context.animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        notifyListeners();
      }
    });
  }

  //PLAYBACKS
  playPause() {
    if (context.animationController.isAnimating) {
      pause();
    } else {
      if (playMode == "oneShot") {
        playForward(from: 0);
      } else if (playMode == "loop") {
        context.animationController.loop();
      } else if (playMode == "pingPong") {
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
        snapToSecond(details.localPosition.dx / context.pixelPerSeconds);

    final pos = (context.time / context.animationController.duration!.inSeconds)
        .clamp(0, 0.99999)
        .toDouble();

    context.animationController
        .animateTo(pos, duration: const Duration(milliseconds: 0));
  }

  animateTo(
    double target, {
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    context.time = context.animationController.duration!.inSeconds * target;

    context.animationController.animateTo(target,
        duration: const Duration(milliseconds: 0), curve: curve);
  }

  changePlaymode(String mode) {
    playMode = mode;
    notifyListeners();
  }

  addKeyframe(
    String objectTrackKey,
    String propertyTrackKey,
    Keyframe keyframe,
  ) {
    readChildController(objectTrackKey)
        ?.readChildController(propertyTrackKey)!
        .addKeyframe(keyframe);
  }

  setDefaultTracks(Map<String, PropertyTrack> defaultTracks) {
    _defaultTracks = defaultTracks;
  }

  ObjectTrackController addObjectTrack(String id, String name) {
    final track = trackedAnimation.objectTracks.putIfAbsent(
      id,
      () {
        return ObjectTrack(
            id: id,
            isCollapsed: false,
            name: name,
            tracks: _defaultTracks ?? {});
      },
    );
    final controller = ObjectTrackController(
      track,
      id,
      context,
    );
    addChildController(id, controller);

    notifyListeners();
    return controller;
  }

  deleteObjectTrack(String id) {
    trackedAnimation.objectTracks.remove(id);
    deleteChildController(id);
    notifyListeners();
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
        selectedKeyframes.union((element) => element.objectId);
    for (var element in totalObjectTracks) {
      readChildController(element.objectId)?.notifyListeners();
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
    readChildController(key)?.toggleCollapse(toggle: toggle);
  }

  moveKeyframe(Keyframe keyframe, double delta) {
    keyframe.time =
        snapToSecond(keyframe.time + (delta / context.pixelPerSeconds))
            .clamp(0, double.infinity);
  }

  onKeyframeSelect(Keyframe key) {
    if (!context.multiSelect) selectedKeyframes.clear();
    selectedKeyframes.add(key);
  }

  exportJson() {
    return trackedAnimation.toJson();
  }

  @override
  void dispose() {
    context.animationController.dispose();
    disposeChildControllers();
    super.dispose();
  }

  // UI Actions
  onPanelSplit(DragUpdateDetails details) {
    context.leftPanelWidth =
        (context.leftPanelWidth + details.delta.dx).clamp(200, 600);
    notifyListeners();
  }

  onZoomScroll(double value) {
    context.pixelPerSeconds = lerpDouble(context.pixelPerSeconds,
        (context.pixelPerSeconds + value).clamp(10, 1000), context.zoomSpeed)!;
    notifyListeners();
  }

  onKeyframeStart(Keyframe keyframe, DragStartDetails details) {}

  onKeyframeMove(Keyframe keyframe, DragUpdateDetails details) {
    if (selectedKeyframes.length > 1) {
      moveSelectedKeyframes(details);
      return;
    }
    moveKeyframe(keyframe, details.delta.dx);
  }
}
