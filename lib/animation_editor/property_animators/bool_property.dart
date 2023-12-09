import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../controllers/property_track_controller.dart';
import 'animator.dart';
import 'property.dart';

class BoolProperty extends AnimationProperty<bool> {
  const BoolProperty();
  @override
  bool lerp(bool a, bool b, double t) {
    if (t == 1) {
      return a;
    }
    if (t == 0) {
      return b;
    }
    return a;
  }

  @override
  bool fromJson(json) => json as bool;

  @override
  dynamic toJson(bool value) => value;

  @override
  Widget buildInpector(
      BuildContext context, PropertyTrackController controller) {
    return Text("Color: ${controller.getAnimation()!.value.toString()}");
  }
}
