import 'package:animation_editor/animation_editor/extentions/list_extentions.dart';

import '../state_magment/controller_manager_mixin.dart';
import '../models/models.dart';
import 'property_track_controller.dart';
import 'tracked_anim_controller.dart';
import 'package:flutter/widgets.dart';
import '../state_magment/controller_query.dart';

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

  final List<Keyframe> unionKeyframes = [];

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

  addPropertyTrack(String key, String name, String dataType, {String? group}) {
    final inspector = inpectorBuilders![key];
    final pTrack = objectTrack.tracks.putIfAbsent(
        key,
        () => PropertyTrack(
            objectTrackKey: this.key,
            key: key,
            name: name,
            group: group ?? "none",
            dataType: dataType,
            keyframes: []));
    addChildController(
        key,
        PropertyTrackController(pTrack, key, context,
            inspectorBuilder: inspector));
    notifyListeners();
  }

  deletePropertyTrack(String key) {
    objectTrack.tracks.remove(key);
    deleteController(key);
    notifyListeners();
  }

  moveAllKeyframesStart(double time, double delta) {
    unionKeyframes.clear();
    for (var propertyTrack in objectTrack.tracks.values) {
      final matched = propertyTrack.keyframes.union((element) => element.time);
      unionKeyframes.addAll(matched);
    }
  }

  moveAllKeyframesUpdate(double time, double delta) {
    for (var keyframe in unionKeyframes) {
      keyframe.time =
          snapToSecond(keyframe.time + (delta / context.pixelPerSeconds))
              .clamp(0, double.infinity);
    }
  }

  movedAllKeyframes() {
    for (var propertyTrackKey in objectTrack.tracks.keys) {
      readChildController(propertyTrackKey)?.createAnimation();
    }
  }

  selectKeyframe(Keyframe keyframe) {
    context.selected.add(keyframe);
    notifyListeners();
  }
}
