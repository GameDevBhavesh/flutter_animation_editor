import 'package:animation_editor/animation_editor/extentions/list_extentions.dart';
import 'package:state_managment/state_magment.dart';

import '../models/models.dart';
import 'property_track_controller.dart';
import 'tracked_anim_controller.dart';
import 'package:flutter/widgets.dart';

class ObjectTrackController extends BaseController
    with MultiControllerManagerMixin<PropertyTrackController> {
  ObjectTrackController(this.objectTrack, this.key, this.context,
      {this.inpectorBuilders}) {
    for (final propertyTrack in objectTrack.tracks.entries) {
      final inspector = inpectorBuilders![propertyTrack.value.dataType];
      addChildController(
          propertyTrack.key,
          PropertyTrackController(
              propertyTrack.value, propertyTrack.key, context,
              inspectorBuilder: inspector));
    }
  }
  final Map<String, Widget Function(PropertyTrackController controller)>?
      inpectorBuilders;

  final AnimationEditorContext context;
  final ObjectTrack objectTrack;
  final String key;

  final List<Keyframe> multipleKeyframes = [];

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

  Animation? getAnimation<J>(String key) {
    if (hasChildController(key)) {
      return readChildController(key)!.getAnimation();
    }
    return null;
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

  toggleCollapse({bool? toggle}) {
    if (toggle != null) {
      objectTrack.isCollapsed = toggle;
    } else {
      objectTrack.isCollapsed = !objectTrack.isCollapsed;
    }
    notifyListeners();
  }

  List<Keyframe<dynamic>> createAllKeyframesUnion() {
    final List<Keyframe> res = [];

    for (var propertyTrack in objectTrack.tracks.values) {
      res.addAll(propertyTrack.keyframes);
    }

    return res.union((element) => element.time);
  }

  addKeyframeOrPropertyTrack(
      String id, String name, Type dataType, dynamic value) {
    if (!hasPropertyTrack(id)) {
      addPropertyTrack(id, name, dataType);
    }
    readChildController(id)!.addKeyframe(Keyframe(
        curve: const Cubic(0, 0, 0, 0),
        time: context.time,
        value: value,
        dataType: dataType,
        objectId: objectTrack.id,
        trackId: id));
    if (objectTrack.isCollapsed) notifyListeners();
    print("${id} ${dataType} added  property");
  }

  bool hasPropertyTrack(String id) {
    return objectTrack.tracks.containsKey(id);
  }

  addPropertyTrack(String id, String name, Type dataType, {String? group}) {
    final inspector = inpectorBuilders![id];
    final pTrack = objectTrack.tracks.putIfAbsent(
        id,
        () => PropertyTrack(
            objectTrackId: this.key,
            id: id,
            name: name,
            group: group ?? "none",
            dataType: dataType,
            keyframes: []));
    addChildController(
        id,
        PropertyTrackController(pTrack, id, context,
            inspectorBuilder: inspector));
    notifyListeners();
  }

  deletePropertyTrack(String key) {
    objectTrack.tracks.remove(key);
    deleteChildController(key);
    notifyListeners();
  }

  moveAllKeyframesStart(double time) {
    multipleKeyframes.clear();
    for (var propertyTrack in objectTrack.tracks.values) {
      for (var frame in propertyTrack.keyframes) {
        if (frame.time == time) {
          multipleKeyframes.add(frame);
        }
      }
    }
  }

  moveAllKeyframesUpdate(double time, double delta) {
    for (var keyframe in multipleKeyframes) {
      keyframe.time = keyframe.time + (delta / context.pixelPerSeconds);
    }
    notifyListeners();
  }

  moveAllKeyframesEnd() {
    for (var propertyTrackKey in objectTrack.tracks.keys) {
      readChildController(propertyTrackKey)?.createAnimation();
    }
    multipleKeyframes.clear();
  }

  selectKeyframe(Keyframe keyframe) {
    context.selected.add(keyframe);
    notifyListeners();
  }
}
