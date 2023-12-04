import 'package:flutter/material.dart';

import '../controllers/tracked_anim_controller.dart';
import '../models/models.dart';

class KeyframeAreaView extends StatelessWidget {
  const KeyframeAreaView({
    super.key,
    this.height = 35,
    required this.onKeyframeMove,
    this.onKeyframeMoveStart,
    this.onKeyframeMoveEnd,
    this.onKeyframeSelected,
    required this.keyframes,
    this.scrollController,
    this.handleBuilder,
    required this.animatorContext,
  });

  //params
  final Function(Keyframe keyframe, DragUpdateDetails details) onKeyframeMove;
  final Function(Keyframe keyframe, DragStartDetails details)?
      onKeyframeMoveStart;
  final Function(Keyframe keyframe, DragEndDetails details)? onKeyframeMoveEnd;
  final Function(Keyframe keyframe)? onKeyframeSelected;

  final List<Keyframe>? keyframes;
  final ScrollController? scrollController;
  final AnimationEditorContext animatorContext;

  final Widget Function(BuildContext context)? handleBuilder;

  //styling
  static const Color backgroundColor = Color.fromARGB(255, 15, 15, 15);
  static const Color borderColor = Color.fromARGB(86, 255, 255, 255);
  final double height;
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: const BoxDecoration(
            color: backgroundColor,
            border: Border.symmetric(
                horizontal: BorderSide(color: borderColor, width: .2))),
        height: height,
        width: MediaQuery.of(context).size.width +
            animatorContext.animationController.duration!.inSeconds *
                animatorContext.pixelPerSeconds +
            300,
        child: Stack(
          children: [
            if (keyframes != null)
              for (final keyframe in keyframes!) buildKeyframe(keyframe),
            ListenableBuilder(
                listenable: animatorContext.animationController,
                child: handleBuilder!(context),
                builder: (context, child) {
                  return Positioned(
                    left: animatorContext.handlePos,
                    child: child!,
                  );
                })
          ],
        ),
      ),
    );
  }

  bool checkSelected(Keyframe keyframe) {
    for (var frame in animatorContext.selected) {
      return keyframe == frame;
    }
    return false;
  }

  Widget buildKeyframe(Keyframe keyframe) {
    bool selected = checkSelected(keyframe);

    return Positioned(
        left: (keyframe.time * animatorContext.pixelPerSeconds) - 20 / 2,
        top: (height / 2) - (20 / 2),
        child: GestureDetector(
          onHorizontalDragStart: (details) {
            if (onKeyframeMoveStart != null) {
              onKeyframeMoveStart!(keyframe, details);
            }
            if (onKeyframeSelected != null) {
              onKeyframeSelected!(keyframe);
            }
          },
          onHorizontalDragUpdate: (details) {
            onKeyframeMove(keyframe, details);
          },
          onHorizontalDragEnd: (details) {
            if (onKeyframeMoveEnd != null) {
              onKeyframeMoveEnd!(keyframe, details);
            }
          },
          onTap: () {
            print("on tap keyframe");
            if (onKeyframeSelected != null) {
              onKeyframeSelected!(keyframe);
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
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
          ),
        ));
  }
}
