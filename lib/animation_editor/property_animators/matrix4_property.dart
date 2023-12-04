import 'dart:math';
import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

import 'package:flutter/widgets.dart';
import '../controllers/property_track_controller.dart';
import 'property.dart';

class Matrix4Property extends AnimationProperty<Matrix4> {
  @override
  Matrix4 lerp(Matrix4 a, Matrix4 b, double t) {
    final Vector3 aTranslation = Vector3.zero();
    final Vector3 endTranslation = Vector3.zero();
    final Quaternion aRotation = Quaternion.identity();
    final Quaternion endRotation = Quaternion.identity();
    final Vector3 aScale = Vector3.zero();
    final Vector3 endScale = Vector3.zero();
    a.decompose(aTranslation, aRotation, aScale);
    b.decompose(endTranslation, endRotation, endScale);
    final Vector3 lerpTranslation =
        aTranslation * (1.0 - t) + endTranslation * t;

    final Quaternion lerpRotation =
        (aRotation.scaled(1.0 - t) + endRotation.scaled(t)).normalized();
    final Vector3 lerpScale = aScale * (1.0 - t) + endScale * t;
    return Matrix4.compose(lerpTranslation, lerpRotation, lerpScale);
  }

  @override
  Matrix4 fromJson(dynamic json) {
    final translation = json['translation'];
    final rotation = json['rotation'];
    final scale = json['scale'];

    final Matrix4 result = Matrix4.identity()
      ..translate(translation['x'].toDouble(), translation['y'].toDouble(),
          translation['z'].toDouble())
      ..rotateZ(rotation['z'].toDouble())
      ..rotateY(rotation['y'].toDouble())
      ..rotateX(rotation['x'].toDouble())
      ..scale(
          scale['x'].toDouble(), scale['y'].toDouble(), scale['z'].toDouble());

    return result;
  }

  @override
  dynamic toJson(Matrix4 a) {
    // Extract translation, rotation, and scale components
    final Vector3 aTranslation = Vector3.zero();
    final Quaternion aRotation = Quaternion.identity();
    final Vector3 aScale = Vector3.zero();
    a.decompose(aTranslation, aRotation, aScale);
    return {
      'translation': {
        'x': aTranslation.x,
        'y': aTranslation.y,
        'z': aTranslation.z
      },
      'rotation': {'x': aRotation.x, 'y': aRotation.y, 'z': aRotation.z},
      'scale': {'x': aScale.x, 'y': aScale.y, 'z': aScale.z},
    };
  }

  @override
  Widget buildInpector(
      BuildContext context, Matrix4 value, PropertyTrackController controller) {
    return Text("Color: ${value.toString()}");
  }
}
