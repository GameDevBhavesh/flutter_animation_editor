import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../controllers/property_track_controller.dart';
import 'animator.dart';
import 'property.dart';

class OffsetProperty extends AnimationProperty<Offset> {
  @override
  Offset lerp(Offset a, Offset b, double t) {
    return Offset.lerp(a, b, t)!;
  }

  @override
  Offset fromJson(json) {
    return Offset(json["dx"].toDouble(), json["dy"].toDouble());
  }

  @override
  Map toJson(Offset value) {
    return {
      "dx": value.dx,
      "dy": value.dy,
    };
  }

  @override
  Widget buildInpector(
      BuildContext context, Offset value, PropertyTrackController controller) {
    return Text("x:${value.dx}, y:${value.dy}");
  }
}
