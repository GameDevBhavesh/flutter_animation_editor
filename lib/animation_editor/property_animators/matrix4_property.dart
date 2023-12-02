// import 'dart:ui';

// import 'package:flutter/widgets.dart';
// import '../controllers/property_track_controller.dart';
// import 'property.dart';

// class Matrix4Property extends AnimationProperty<Matrix4> {
//   @override
//   Matrix4 lerp(Matrix4 a, Matrix4 b, double t) {
//     assert(a != null);
//     assert(end != null);
//     final Vector3 aTranslation = Vector3.zero();
//     final Vector3 endTranslation = Vector3.zero();
//     final Quaternion aRotation = Quaternion.identity();
//     final Quaternion endRotation = Quaternion.identity();
//     final Vector3 aScale = Vector3.zero();
//     final Vector3 endScale = Vector3.zero();
//     a!.decompose(aTranslation, aRotation, aScale);
//     end!.decompose(endTranslation, endRotation, endScale);
//     final Vector3 lerpTranslation =
//         aTranslation * (1.0 - t) + endTranslation * t;
//     // TODO(alangardner): Implement lerp for constant rotation
//     final Quaternion lerpRotation =
//         (aRotation.scaled(1.0 - t) + endRotation.scaled(t)).normalized();
//     final Vector3 lerpScale = aScale * (1.0 - t) + endScale * t;
//     return Matrix4.compose(lerpTranslation, lerpRotation, lerpScale);
//   }

//   @override
//   Color fromJson(json) => Color(int.parse(json.toInt()));

//   @override
//   dynamic toJson(Color value) => value.value;

//   @override
//   Widget buildInpector(
//       BuildContext context, Color value, PropertyTrackController controller) {
//     return Text("Color: ${value.value}");
//   }
// }
