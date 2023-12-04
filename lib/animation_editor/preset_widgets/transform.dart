import 'package:animation_editor/animation_editor.dart';
import 'package:flutter/material.dart';

class KeyframedTransform extends StatelessWidget {
  const KeyframedTransform({
    Key? key,
    required this.child,
    required this.transform,
    this.alignment = Alignment.center,
  }) : super(key: key);

  final Widget child;
  final AlignmentGeometry alignment;
  final Matrix4 transform;
  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: alignment,
      transform: context.readAnim("transform", transform),
      child: child,
    );
  }
}
