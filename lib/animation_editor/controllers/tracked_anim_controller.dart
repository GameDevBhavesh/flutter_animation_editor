import 'dart:ui';

import 'package:animation_editor/animation_editor/controllers/property_track_controller.dart';
import 'package:animation_editor/animation_editor/state_magment/controller_query.dart';
import 'package:animation_editor/animation_editor/widgets/property_track_view.dart';
// import 'package:animation_editor/src/controller.dart';
import 'package:animation_editor/animation_editor/extentions/anim_extention.dart';
import 'package:animation_editor/animation_editor/extentions/list_extentions.dart';
import 'package:flutter/material.dart';
import 'package:state_managment/state_magment.dart';

import '../property_animators/double_property.dart';
import '../state_magment/controller_manager_mixin.dart';
import '../models/models.dart';
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
  TrackedAnimationController(this.trackedAnimation, this.vsync,
      {this.configuration}) {
    initAnimatorEvents();
    for (final objTrack in trackedAnimation.objectTracks.entries) {
      addChildController(
          objTrack.key,
          ObjectTrackController(objTrack.value, objTrack.key, context,
              inpectorBuilders: configuration?.propertyInspectorBuilder));
    }
  }
  final AnimationEditorConfiguration? configuration;

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

  addObjectTrack(String key, String name) {
    final track = trackedAnimation.objectTracks.putIfAbsent(
      key,
      () {
        return ObjectTrack(
            isCollapsed: false, name: name, tracks: _defaultTracks ?? {});
      },
    );
    addChildController(
        key,
        ObjectTrackController(track, key, context,
            inpectorBuilders: configuration?.propertyInspectorBuilder));
    notifyListeners();
  }

  deleteObjectTrack(String key) {
    trackedAnimation.objectTracks.remove(key);
    deleteChildController(key);
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
        selectedKeyframes.union((element) => element.objectKey);
    for (var element in totalObjectTracks) {
      readChildController(element.objectKey)?.notifyListeners();
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

class ValueParser<T> {
  const ValueParser({required this.toJson, required this.fromJson});
  final Map<String, dynamic> Function(T value) toJson;
  final T Function(Map<String, dynamic> json) fromJson;
}

class AnimationEditorConfiguration {
  const AnimationEditorConfiguration(
      {required this.valueParsers, required this.propertyInspectorBuilder});

  //How to parse v
  final Map<String, ValueParser> valueParsers;
  final Map<String, Widget Function(PropertyTrackController controller)>
      propertyInspectorBuilder;

  factory AnimationEditorConfiguration.defaults() {
    return AnimationEditorConfiguration(valueParsers: {
      "offset": ValueParser<Offset>(
        fromJson: (json) => Offset(
          json["dx"].toDouble(),
          json["dy"].toDouble(),
        ),
        toJson: (value) => {"dx": value.dx, "dy": value.dy},
      ),
      "color": ValueParser<Color>(
        fromJson: (json) => Color(int.parse(json["value"])),
        toJson: (value) => {"value": value.toString()},
      ),
      "double": ValueParser<double>(
        fromJson: (json) => json["value"].toDouble(),
        toJson: (value) => {"value": value},
      ),
    }, propertyInspectorBuilder: {
      "offset": (PropertyTrackController controller) {
        final anim = controller.getAnimation();
        if (anim == null) return const SizedBox();
        return AnimatedBuilder(
            animation: anim,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    anim.value.dx.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    anim.value.dy.toString(),
                    style: TextStyle(color: Colors.white),
                  )
                ],
              );
            });
      },
      "color": (PropertyTrackController controller) {
        final anim = controller.getAnimation();
        if (anim == null) return const SizedBox();
        return AnimatedBuilder(
            animation: anim,
            builder: (context, child) {
              return Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: anim.value,
                        borderRadius: BorderRadius.circular(5)),
                  ),
                ),
              );
            });
      },
      "double": (PropertyTrackController controller) {
        return DoubleInspector(controller: controller);
      }
    });
  }
}
