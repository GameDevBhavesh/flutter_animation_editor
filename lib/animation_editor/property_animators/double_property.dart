import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../controllers/property_track_controller.dart';
import 'property.dart';

class DoubleProperty extends AnimationProperty<double> {
  const DoubleProperty();
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
      BuildContext context, PropertyTrackController controller) {
    return Text(
        "${controller.track.name}: ${controller.getAnimation()!.value.toString()}");
  }
}

class IntProperty extends AnimationProperty<int> {
  const IntProperty();
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
      BuildContext context, PropertyTrackController controller) {
    return Text(
        "${controller.track.name}: ${controller.getAnimation()!.value.toString()}");
  }
}

class NumProperty extends AnimationProperty<num> {
  const NumProperty();
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
      BuildContext context, PropertyTrackController controller) {
    return DoubleInspector(
      controller: controller,
    );
  }
}

class DoubleInspector extends StatefulWidget {
  const DoubleInspector({super.key, required this.controller});
  final PropertyTrackController controller;
  @override
  State<DoubleInspector> createState() => _DoubleInspectorState();
}

class _DoubleInspectorState extends State<DoubleInspector> {
  late TextEditingController textController = TextEditingController(text: "0");
  Animation<dynamic>? anim;
  @override
  void initState() {
    updateAnim();
    widget.controller.onAnimationChange.addListener(updateAnim);
    super.initState();
  }

  updateAnim() async {
    setState(() {
      anim = widget.controller.getAnimation();
    });
    if (anim != null) anim!.addListener(onAnimation);
  }

  onAnimation() {
    textController.text = (anim!.value as num).toStringAsFixed(2).toString();
    final keyed = widget.controller.hasKeyframeOnTime();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (anim == null) return const SizedBox();
    final keyed = widget.controller.hasKeyframeOnTime();
    return SizedBox(
      width: 200,
      child: TextField(
        style: TextStyle(
            color: keyed != null
                ? Color.fromARGB(255, 0, 179, 211)
                : Colors.white),
        textAlign: TextAlign.center,
        controller: textController,
        onSubmitted: (value) {
          widget.controller.addCurrentKeyframe(value: double.parse(value));
        },
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.onAnimationChange.removeListener(updateAnim);
    if (anim != null) {
      anim!.removeListener(onAnimation);
    }
    super.dispose();
  }
}
