import 'package:animation_editor/animation_editor/controllers/property_track_controller.dart';
import 'package:animation_editor/animation_editor/widgets/keyframes_area_view.dart';
import 'package:animation_editor/animation_editor/widgets/property_track_view.dart';
import 'package:animation_editor/animation_editor/extentions/list_extentions.dart';

import 'package:flutter/material.dart';

import '../controllers/object_track_controller.dart';
import '../models/models.dart';

class ObjectTrackView extends StatelessWidget {
  const ObjectTrackView(
      {super.key,
      required this.controller,
      this.onExpand,
      this.height = 35,
      this.splitViewBuilder,
      this.inspectorBuilder});

  //final AnimationEditorController controller
  final ObjectTrackController controller;
  final Widget Function(BuildContext context)? inspectorBuilder;

  //final String headerTitleText
  final Function()? onExpand;
  final Widget Function(BuildContext context)? splitViewBuilder;
  final double height;
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
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          Widget childs = Column(
            children: [
              for (final key in controller.objectTrack.tracks.keys)
                PropertyTrackView(
                  height: height,
                  inspectorBuilder: controller.inpectorBuilders![
                      controller.objectTrack.tracks[key]!.dataType],
                  controller: controller.readChildController(key)!,
                  splitViewBuilder: splitViewBuilder,
                )
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHeader(context),
              if (!controller.objectTrack.isCollapsed) childs!
            ],
          );
        },
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
              width: controller.context.leftPanelWidth,
              constraints: const BoxConstraints(minWidth: 280),
              child: Row(
                children: [
                  Icon(
                    controller.objectTrack.isCollapsed
                        ? Icons.arrow_right
                        : Icons.arrow_drop_down_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                  Text(
                    controller.objectTrack.name,
                    style: const TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            if (splitViewBuilder != null) splitViewBuilder!(context),
            Expanded(
              child: KeyframeAreaView(
                keyframes: (controller.objectTrack.isCollapsed)
                    ? controller.createAllKeyframesUnion()
                    : null,
                animatorContext: controller.context,
                handleBuilder: (context) {
                  return Container(
                      color: handleColor,
                      width: handleWidth,
                      height: MediaQuery.of(context).size.height);
                },
                onKeyframeMoveStart: (keyframe, details) {
                  controller.moveAllKeyframesStart(keyframe.time);
                },
                onKeyframeMoveUpdate: (keyframe, details) {
                  controller.moveAllKeyframesUpdate(
                      keyframe.time, details.delta.dx);
                },
                onKeyframeMoveEnd: (keyframe, details) {
                  controller.moveAllKeyframesEnd();
                },
                onKeyframeSelected: (keyframe) {
                  controller.selectKeyframe(keyframe);
                },
                // maxDuration: duration
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Keyframe> getUnionKeyframes() {
    final List<Keyframe> res = [];
    for (var propertyTrack in controller.objectTrack.tracks.values) {
      res.addAll(propertyTrack.keyframes.union((element) => element.time));
    }
    return res;
  }
}
