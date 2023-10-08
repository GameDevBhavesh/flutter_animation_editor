import 'package:flutter/material.dart';

import '../controller.dart';
import '../models.dart';
import 'keyframes_row.dart';

class TimelineTrackView extends StatelessWidget {
  const TimelineTrackView(
      {super.key,
      this.controller,
      required this.onToggle,
      required this.track,
      required this.onKeyframeMove,
      required this.handleLineColor,
      required this.handleLineWidth,
      this.rowHeight = 50,
      this.splitView,
      required this.child});

  final Function() onToggle;
  final Track track;
  final Widget child;

  final double rowHeight;
  final double handleLineWidth;
  final Color handleLineColor;
  final Widget? splitView;

  final bool alwaysShowUnionKeyframes = false;

  final AnimationEditorController? controller;
  final Function(Keyframe key, DragUpdateDetails details) onKeyframeMove;

  //styling
  static const Color backgroundColor = Color.fromARGB(255, 15, 15, 15);
  static const Color borderColor = Color.fromARGB(86, 255, 255, 255);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 28, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              onToggle();
            },
            child: Container(
              height: rowHeight,
              decoration: const BoxDecoration(
                  color: backgroundColor,
                  border: Border.symmetric(
                      horizontal: BorderSide(color: borderColor, width: .2))),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: controller!.leftPanelWidth,
                    child: Row(
                      children: [
                        Icon(
                          track.isCollapsed
                              ? Icons.arrow_right
                              : Icons.arrow_drop_down_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                        Text(
                          track.name,
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  if (splitView != null) splitView!,
                  Expanded(
                    child: KeyframesRow(
                      controller: controller,
                      handleLineColor: handleLineColor,
                      handleLineWidth: handleLineWidth,
                      // pixelPerSeconds:c pixelPerSeconds,
                      // handleTime: handleTime,
                      onKeyframeMove: onKeyframeMove,
                      keyframes: (alwaysShowUnionKeyframes || track.isCollapsed)
                          ? getUnionKeyframes()
                          : null,
                      // maxDuration: duration
                    ),
                  )
                ],
              ),
            ),
          ),
          if (!track.isCollapsed) child
        ],
      ),
    );
  }

  List<Keyframe> getUnionKeyframes() {
    Set<Keyframe> unionSet = {};
    track.keyframes.entries.forEach((element) {
      unionSet.addAll(element.value);
    });
    return unionSet.toList();
  }
}
