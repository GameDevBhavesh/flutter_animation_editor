import 'dart:math';

import 'package:flutter/material.dart' as mat;
import 'package:vector_math/vector_math_64.dart';

import 'package:flutter/widgets.dart';
import '../controllers/property_track_controller.dart';
import 'property.dart';

class Matrix4Property extends AnimationProperty<Matrix4> {
  const Matrix4Property();
  @override
  Matrix4 lerp(Matrix4 a, Matrix4 b, double t) {
    if (t == 0) return a;
    if (t == 1) return b;
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
  dynamic toJson(Matrix4 value) {
    // Extract translation, rotation, and scale components
    final Vector3 aTranslation = Vector3.zero();
    final Quaternion aRotation = Quaternion.identity();
    final Vector3 aScale = Vector3.zero();
    value.decompose(aTranslation, aRotation, aScale);
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
      BuildContext context, PropertyTrackController controller) {
    return mat.TextButton(
        onPressed: () {
          final anim = controller.getAnimation();
          mat.showDialog(
            context: context,
            builder: (context) {
              return mat.AnimatedBuilder(
                  animation: anim!,
                  builder: (context, c) {
                    final trans = (anim.value as Matrix4).getTranslation();
                    return MatrixInspectorDialog(initialMatrix: anim.value);
                  });
            },
          );
        },
        child: const Icon(
          mat.Icons.edit_square,
          color: mat.Colors.white,
        ));
  }
}

class MatrixInspectorDialog extends StatefulWidget {
  final Matrix4 initialMatrix;

  MatrixInspectorDialog({required this.initialMatrix});

  @override
  _MatrixInspectorDialogState createState() => _MatrixInspectorDialogState();
}

class _MatrixInspectorDialogState extends State<MatrixInspectorDialog> {
  late double translationX;
  late double translationY;
  late double rotation;
  late double scaling;

  @override
  void initState() {
    super.initState();
    Vector3 translation = Vector3.zero();
    Quaternion rot = Quaternion.identity();
    Vector3 scale = Vector3.zero();
    final decomposedValues =
        widget.initialMatrix.decompose(translation, rot, scale);
    translationX = translation.x;
    translationY = translation.y;
    rotation = rot.z;
    scaling = scale.x;
  }

  @override
  Widget build(BuildContext context) {
    return mat.AlertDialog(
      title: Text('Matrix Inspector Dialog'),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Transformation Matrix:'),
            Text(widget.initialMatrix.toString()),
            SizedBox(height: 20),
            Transform(
              transform: widget.initialMatrix,
              child: Container(
                width: 100,
                height: 100,
                color: mat.Colors.blue,
                child: Center(
                  child: Text('Inspect Me!'),
                ),
              ),
            ),
            SizedBox(height: 20),
            _buildSlider('Translation X', translationX, -100, 100, (value) {
              setState(() {
                translationX = value;
              });
            }),
            _buildSlider('Translation Y', translationY, -100, 100, (value) {
              setState(() {
                translationY = value;
              });
            }),
            _buildSlider('Rotation', rotation, -pi, pi, (value) {
              setState(() {
                rotation = value;
              });
            }),
            _buildSlider('Scaling', scaling, 0.1, 2.0, (value) {
              setState(() {
                scaling = value;
              });
            }),
          ],
        ),
      ),
      actions: [
        mat.TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      children: [
        Text(label),
        mat.Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          label: value.toString(),
        ),
      ],
    );
  }
}
