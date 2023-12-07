import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../controllers/property_track_controller.dart';

import 'property.dart';

class ColorProperty extends AnimationProperty<Color> {
  const ColorProperty();
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
    final anim = controller.getAnimation();
    if (anim == null) return const SizedBox();
    return AnimatedBuilder(
        animation: anim,
        builder: (context, child) {
          return Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    // border: Border.all(color: Colors.white, width: 1),
                    shape: BoxShape.rectangle,
                    color: anim.value,
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
          );
        });
  }
}
