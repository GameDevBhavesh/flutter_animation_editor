import 'package:flutter/widgets.dart';

import '../controllers/property_track_controller.dart';

abstract class AnimationProperty<Type> {
  const AnimationProperty();
  Type lerp(Type a, Type b, double t);
  Type fromJson(dynamic json);
  dynamic toJson(Type value);
  Widget buildInpector(
      BuildContext context, Type value, PropertyTrackController controller);
}
