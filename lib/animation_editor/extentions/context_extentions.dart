import 'package:flutter/widgets.dart';

import '../../animation_editor.dart';
import './anim_extention.dart';
import '../state_magment/controller_query.dart';

extension ContextHelp on BuildContext {
  ObjectTrackController? getObjectTrack() {
    return ControllerQuery.of<ObjectTrackController>(this);
  }

  T readAnim<T>(String animKey, T defaultValue) {
    final track = ControllerQuery.of<ObjectTrackController>(this);
    if (track != null) {
      return track.getAnimation(animKey).valueOrDefault<T>(defaultValue);
    }
    return defaultValue;
  }

  Animation<dynamic>? getAnim(String animKey) {
    final track = ControllerQuery.of<ObjectTrackController>(this);
    if (track != null) {
      return track.getAnimation(animKey)!;
    }
    return null;
  }
}
