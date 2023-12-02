import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../controllers/property_track_controller.dart';
import 'property.dart';

class DoubleProperty extends AnimationProperty<double> {
  @override
  double lerp(double a, double b, double t) {
    if (a is int) {
      return lerpDouble(a.toDouble(), b.toDouble(), t)!;
    }
    return lerpDouble(a, b, t)!;
  }

  @override
  double fromJson(json) => json.toDouble();

  @override
  dynamic toJson(double value) => value;

  @override
  Widget buildInpector(
      BuildContext context, num value, PropertyTrackController controller) {
    return Text("${controller.track.name}: $value");
  }
}
