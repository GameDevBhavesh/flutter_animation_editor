import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../controllers/property_track_controller.dart';
import 'animator.dart';
import 'property.dart';

class ColorProperty extends AnimationProperty<Color> {
  @override
  Color lerp(Color a, Color b, double t) {
    return Color.lerp(a, b, t)!;
  }

  @override
  Color fromJson(json) => Color(int.parse(json.toInt()));

  @override
  dynamic toJson(Color value) => value.value;

  @override
  Widget buildInpector(
      BuildContext context, Color value, PropertyTrackController controller) {
    return Text("Color: ${value.value}");
  }
}
