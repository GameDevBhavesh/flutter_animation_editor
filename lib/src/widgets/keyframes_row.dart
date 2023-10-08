import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';

class KeyframesRow extends StatelessWidget {
  const KeyframesRow(
      {super.key,
      required this.handleLineColor,
      required this.handleLineWidth,
      required this.onKeyframeMove,
      this.onKeyframeSelected,
      required this.keyframes,
      this.scrollController,
      this.valueBuilder,
      this.controller});

  final AnimationEditorController? controller;
  //params
  final Function(Keyframe keyframe, DragUpdateDetails details) onKeyframeMove;
  final Function(Keyframe keyframe)? onKeyframeSelected;

  final List<Keyframe>? keyframes;
  final ScrollController? scrollController;
  final double handleLineWidth;
  final Color handleLineColor;

  final Map<Type, Widget Function(BuildContext context, Keyframe keyframe)>?
      valueBuilder;

  //styling
  static const Color backgroundColor = Color.fromARGB(255, 15, 15, 15);
  static const Color borderColor = Color.fromARGB(86, 255, 255, 255);
  static double height = 50;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: backgroundColor,
          border: Border.symmetric(
              horizontal: BorderSide(color: borderColor, width: .2))),
      // height: height,
      width: MediaQuery.of(context).size.width +
          controller!.animationController.duration!.inSeconds *
              controller!.pixelPerSeconds +
          300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // const ColoredBox(
          //   color: Colors.white,
          //   child: SizedBox(
          //     width: 5,
          //   ),
          // ),
          Expanded(
            child: Stack(
              children: [
                if (keyframes != null)
                  for (final keyframe in keyframes!) buildKeyframe(keyframe),
                Positioned(
                  left: controller!.time * controller!.pixelPerSeconds,
                  child: Container(
                    color: handleLineColor,
                    height: MediaQuery.of(context).size.height,
                    width: handleLineWidth,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool checkSelected(Keyframe keyframe) {
    for (var frame in controller!.selectedKeyframes) {
      return keyframe.id == frame.id;
    }
    return false;
  }

  Widget buildKeyframe(Keyframe keyframe) {
    bool selected = checkSelected(keyframe);

    return Positioned(
        left: (keyframe.time * controller!.pixelPerSeconds) - 20 / 2,
        top: (height / 2) - (20 / 2),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            onKeyframeMove(keyframe, details);
          },
          onHorizontalDragStart: (details) {
            if (onKeyframeSelected != null) {
              onKeyframeSelected!(keyframe);
            }
          },
          onTap: () {
            if (onKeyframeSelected != null) {
              onKeyframeSelected!(keyframe);
            }
          },
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              color: Color.fromARGB(45, 255, 242, 0),
              height: 20,
              width: 20,
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  color: selected
                      ? Color.fromARGB(255, 23, 230, 203)
                      : const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ),
        ));
  }
}
