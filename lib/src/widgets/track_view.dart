import 'package:animation_editor/animation_editor.dart';
import 'package:animation_editor/src/widgets/map_editor.dart';
import 'package:flutter/material.dart';
import 'keyframes_row.dart';

class TrackView extends StatelessWidget {
  const TrackView({
    super.key,
    required this.track,
    required this.controller,
    this.onExpand,
    this.splitViewBuilder,
    required this.onKeyframeEnd,
    required this.onKeyframeMove,
    required this.onKeyframeMoveHeader,
    required this.onKeyframeSelected,
    required this.onKeyframeSelectedHeader,
    required this.onKeyframeEndHeader,
  });

  final AnimationEditorController controller;
  final Track track;

  //final String headerTitleText
  final Function()? onExpand;
  final Widget Function(BuildContext context)? splitViewBuilder;

  //callbacks
  final Function(Keyframe key, DragUpdateDetails details) onKeyframeMoveHeader;
  final Function(Keyframe key) onKeyframeSelectedHeader;
  final Function(Keyframe key, DragEndDetails details) onKeyframeEndHeader;

  final Function(Keyframe key, DragUpdateDetails details) onKeyframeMove;
  final Function(Keyframe key) onKeyframeSelected;
  final Function(Keyframe key, DragEndDetails details, String keyframesKey)
      onKeyframeEnd;

  static double height = 45;
  static const Color backgroundColor = Color.fromARGB(255, 15, 15, 15);
  static const Color borderColor = Color.fromARGB(255, 122, 122, 122);
  static const TextStyle textStyle = TextStyle(color: Colors.white);

  //handle
  static const Color handleColor = Color.fromARGB(255, 7, 193, 222);
  static const double handleWidth = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          if (!track.isCollapsed)
            for (final keyframes in track.keyframes.entries)
              buildChild(context, keyframes)
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: onExpand,
      child: Container(
        height: height,
        decoration: const BoxDecoration(
            color: backgroundColor,
            border: Border.symmetric(
                horizontal: BorderSide(color: borderColor, width: .2))),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: controller.leftPanelWidth,
              constraints: const BoxConstraints(minWidth: 200),
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
            if (splitViewBuilder != null) splitViewBuilder!(context),
            Expanded(
              child: KeyframesRow(
                controller: controller,
                handleBuilder: (context) {
                  return Container(
                      color: handleColor,
                      width: handleWidth,
                      height: MediaQuery.of(context).size.height);
                },
                onKeyframeMove: onKeyframeMoveHeader,
                onKeyframeMoveEnd: onKeyframeEndHeader,
                onKeyframeSelected: onKeyframeSelectedHeader,
                keyframes: (track.isCollapsed) ? getUnionKeyframes() : null,
                // maxDuration: duration
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildChild(
      BuildContext context, MapEntry<String, List<Keyframe>> keyframesEntry) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Container(
            width: controller.leftPanelWidth,
            constraints: const BoxConstraints(minWidth: 200),
            alignment: Alignment.center,
            color: const Color.fromARGB(255, 40, 40, 40).withOpacity(0),
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  keyframesEntry.key,
                  style: textStyle,
                ),
              ],
            ),
          ),
          if (splitViewBuilder != null) splitViewBuilder!(context),
          Expanded(
              child: KeyframesRow(
            controller: controller,
            handleBuilder: (context) {
              return Container(
                  color: handleColor,
                  width: handleWidth,
                  height: MediaQuery.of(context).size.height);
            },
            onKeyframeMove: (frame, details) {
              onKeyframeMove(frame, details);
              // controller.onKeyframeMove(frame, details);
            },
            onKeyframeSelected: (keyframe) {
              onKeyframeSelected(keyframe);
              // controller.onKeyframeSelect(keyframe);
            },
            onKeyframeMoveEnd: (keyframe, details) {
              onKeyframeEnd(keyframe, details, keyframesEntry.key);
              // controller.generateTrackAnimationMap(
              //     trackKey, keyframesEntry.key);
            },
            keyframes: keyframesEntry.value,
          ))
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
