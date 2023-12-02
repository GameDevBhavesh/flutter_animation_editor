import 'package:animation_editor/animation_editor.dart';
import 'package:flutter/material.dart';

class KeyframedTransform extends StatelessWidget {
  final Widget child;
  final double scaleX;
  final double scaleY;
  final double rotationX;
  final double rotationY;
  final double rotationZ;
  final double translationX;
  final double translationY;
  final double translationZ;
  final AlignmentGeometry alignment;

  const KeyframedTransform({
    Key? key,
    required this.child,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.rotationX = 0.0,
    this.rotationY = 0.0,
    this.rotationZ = 0.0,
    this.translationX = 0.0,
    this.translationY = 0.0,
    this.translationZ = 0.0,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: alignment,
      transform: Matrix4.identity()
        ..translate(
            context.readAnim("transform:pos:x", translationX),
            context.readAnim("transform:pos:y", translationY),
            context.readAnim("transform:pos:z", translationZ))
        ..rotateX(context.readAnim("transform:rot:x", rotationX))
        ..rotateY(context.readAnim("transform:rot:y", rotationY))
        ..rotateZ(context.readAnim("transform:rot:z", rotationZ))
        ..scale(context.readAnim("transform:scal:x", scaleX),
            context.readAnim("transform:scal:y", scaleY)),
      child: child,
    );
  }
}
