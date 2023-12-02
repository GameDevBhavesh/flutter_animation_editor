import 'package:flutter/material.dart';

import '../controllers/object_track_controller.dart';
import '../controllers/property_track_controller.dart';
import '../models/models.dart';
import 'keyframes_area_view.dart';

class PropertyTrackView extends StatelessWidget {
  const PropertyTrackView(
      {super.key,
      this.height = 35,
      required this.controller,
      this.splitViewBuilder,
      this.inspectorBuilder});

  final PropertyTrackController controller;

  final Widget Function(BuildContext context)? splitViewBuilder;
  final Widget Function(PropertyTrackController control)? inspectorBuilder;

  final double height;
  static const Color backgroundColor = Color.fromARGB(255, 15, 15, 15);
  static const Color borderColor = Color.fromARGB(255, 122, 122, 122);
  static const TextStyle textStyle = TextStyle(color: Colors.white);

  //handle
  static const Color handleColor = Color.fromARGB(255, 7, 193, 222);
  static const double handleWidth = 2;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: controller,
        builder: (context, c) {
          return SizedBox(
            height: height,
            child: Row(
              children: [
                Container(
                  width: controller.context.leftPanelWidth,
                  constraints: const BoxConstraints(minWidth: 280),
                  alignment: Alignment.center,
                  color: Color.fromARGB(255, 27, 27, 27).withOpacity(1),
                  // height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Text(
                          controller.track.name,
                          style: textStyle,
                        ),
                      ),
                      // const SizedBox(width: 10),
                      if (inspectorBuilder != null)
                        Expanded(child: inspectorBuilder!(controller)),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          controller.addRemoveCurrentKeyframe();
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Center(
                              child: Container(
                                  transformAlignment: Alignment.center,
                                  transform: Matrix4.rotationZ(.8),
                                  width: 10,
                                  height: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: Container(
                                      color: Colors.black,
                                    ),
                                  ),
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
                if (splitViewBuilder != null) splitViewBuilder!(context),
                Expanded(
                    child: ListenableBuilder(
                        listenable: controller.keyframesNotifer,
                        builder: (context, c) {
                          return KeyframeAreaView(
                            height: height,
                            animatorContext: controller.context,
                            keyframes: controller.track.keyframes,
                            handleBuilder: (context) {
                              return Container(
                                  color: handleColor,
                                  width: handleWidth,
                                  height: MediaQuery.of(context).size.height);
                            },
                            onKeyframeMove: (frame, details) {
                              controller.moveKeyframe(frame, details.delta.dx);
                            },
                            onKeyframeSelected: (keyframe) {
                              controller.selectKeyframe(keyframe);
                            },
                            onKeyframeMoveEnd: (keyframe, details) {
                              controller.movedKeyframe(keyframe);
                            },
                          );
                        }))
              ],
            ),
          );
        });
  }
}
