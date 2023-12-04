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

class IntProperty extends AnimationProperty<int> {
  @override
  int lerp(int a, int b, double t) {
    return lerpDouble(a.toDouble(), b.toDouble(), t)!.toInt();
  }

  @override
  int fromJson(json) => json.toInt();

  @override
  dynamic toJson(int value) => value;

  @override
  Widget buildInpector(
      BuildContext context, num value, PropertyTrackController controller) {
    return Text("${controller.track.name}: $value");
  }
}

class NumProperty extends AnimationProperty<num> {
  @override
  num lerp(num a, num b, double t) {
    return lerpDouble(a.toDouble(), b.toDouble(), t)!.toDouble();
  }

  @override
  num fromJson(json) => json.toInt();

  @override
  dynamic toJson(num value) => value;

  @override
  Widget buildInpector(
      BuildContext context, num value, PropertyTrackController controller) {
    return Text("${controller.track.name}: $value");
  }
}
