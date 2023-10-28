import 'dart:convert';

import 'package:animation_editor/src/widgets/map_editor.dart';
import 'package:animation_editor/src/widgets/track_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'controller.dart';
import 'models.dart';

import 'widgets/keyframe_row_leading.dart';
import 'widgets/keyframes_row.dart';
import 'widgets/timeline_track_view.dart';

class AnimationEditor extends StatelessWidget {
  const AnimationEditor(
      {super.key,
      required this.controller,
      this.handleBuilder,
      this.handleLineWidth = .5,
      this.valueBuilder,
      this.handleLineColor = Colors.white});
  final AnimationEditorController controller;

  final Widget Function(BuildContext context)? handleBuilder;

  final double handleLineWidth;
  final Color handleLineColor;
  static TextStyle style = const TextStyle(color: Colors.white);

  static double trackRowHeight = 100;
  static double keyframeRowHeight = 50;

  static double topbarHeight = 45;
  final Map<String, Widget Function(BuildContext context, Keyframe? keyframe)>?
      valueBuilder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Material(
          color: const Color.fromARGB(255, 0, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        buildTopbar(context),
                        buildTopbarOverlay(context)
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Stack(
                          children: [
                            buildBody(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.selectedKeyframes.isNotEmpty)
                Container(
                  width: 200,
                  color: const Color.fromARGB(255, 41, 41, 41),
                  child: ListenableBuilder(
                      listenable: controller.keyframeUpdateNotifier,
                      builder: (context, c) {
                        if ((controller.selectedKeyframes.isEmpty))
                          return const SizedBox();
                        return Column(
                          children: [
                            Container(
                              color: Colors.black,
                              height: 45,
                              alignment: Alignment.center,
                              child: Text(
                                controller.selectedKeyframes.last.itemId,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            MapEditor(
                                key: Key(controller.selectedKeyframes.last.id!),
                                onValueSubmit: (key, value, type) {
                                  controller.editSelectedKeyframeValue(
                                      key, value);
                                },
                                map: controller
                                    .selectedKeyframes.last.propertyValue)
                          ],
                        );
                      }),
                )
            ],
          ),
        );
      },
    );
  }

  Widget buildBodyOverlay(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(
          width: 200,
        ),
        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerSignal: (PointerSignalEvent event) {
                if (event is PointerScrollEvent &&
                    event.kind == PointerDeviceKind.mouse) {
                  double scrollDelta = event.scrollDelta.dy;
                  controller.onZoomScroll(scrollDelta);
                  // Do something with the middle mouse button scroll value (scrollDelta)
                }
              },
              child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    controller.onTimeHandleDrag(details);
                  },
                  child: Container(
                    color: Colors.white.withOpacity(.3),
                  )),
            ),
          ),
        )
      ],
    );
  }

  Widget buildBody() {
    return ListenableBuilder(
        listenable: Listenable.merge(
          [controller.keyframeUpdateNotifier, controller.animationController],
        ),
        builder: (context, c) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final track in controller.timelineEntity.tracks.entries)
                TrackView(
                  track: track.value,
                  controller: controller,
                  splitViewBuilder: (context) {
                    return buildSpliter(context);
                  },
                  onExpand: () {
                    controller.toggleTrack(track.value);
                  },
                  onKeyframeEnd: (key, details, keyframesKey) {
                    controller.generateTrackAnimationMap(
                        track.key, keyframesKey);
                  },
                  onKeyframeMove: (key, details) {
                    controller.onKeyframeMove(key, details);
                  },
                  onKeyframeMoveHeader: (key, details) {
                    controller.moveUnionKeyframes(
                        track.value, key.time, details);
                  },
                  onKeyframeSelected: (key) {
                    controller.onKeyframeSelect(key);
                  },
                  onKeyframeSelectedHeader: (key) {
                    controller.onKeyframeSelect(key);
                  },
                  onKeyframeEndHeader: (key, details) {
                    controller.onKeyframeSelect(key);
                  },
                )
            ],
          );
        });
  }

  Widget buildSpliter(BuildContext context) {
    return MouseRegion(
        cursor: SystemMouseCursors.resizeLeftRight,
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            controller.onPanelSplit(details);
          },
          onVerticalDragUpdate: (details) {},
          child: Container(
            color: const Color.fromARGB(255, 39, 39, 39),
            width: 5,
            height: MediaQuery.of(context).size.height,
          ),
        ));
  }

  Widget buildTopbar(BuildContext context) {
    return SizedBox(
      height: topbarHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            width: controller.leftPanelWidth,
            color: const Color.fromARGB(0, 20, 20, 20),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      controller.playPause();
                    },
                    icon: Icon(
                        controller.animationController.isAnimating
                            ? Icons.pause_sharp
                            : Icons.play_arrow_outlined,
                        size: 30,
                        color: Colors.white)),
                DropdownButton<String>(
                    style: const TextStyle(color: Colors.white),
                    value: controller.timelineEntity.playType,
                    dropdownColor: const Color.fromARGB(255, 16, 16, 16),
                    items: const [
                      DropdownMenuItem<String>(
                          value: "loop", child: Text("Loop")),
                      DropdownMenuItem<String>(
                          value: "oneShot", child: Text("OneShot")),
                      DropdownMenuItem<String>(
                          value: "pingPong", child: Text("PingPong"))
                    ],
                    onChanged: (val) {
                      controller.setPlayType(val!);
                    }),
                SizedBox(
                    width: 60,
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: controller.timelineDurationTextController,
                      onSubmitted: (value) {
                        controller.onTimelinDurationChange(value);
                      },
                    ))
              ],
            ),
          ),
          buildSpliter(context),
          Expanded(
            child: SizedBox(
              // height: 30,
              child: Stack(
                // fit: StackFit.expand,
                children: [
                  Positioned(
                      bottom: 0,
                      child: Container(
                        height: 2,
                        width: MediaQuery.of(context).size.width,
                        color: const Color.fromARGB(132, 255, 255, 255),
                      )),
                  for (int i = 0;
                      i <=
                          (controller.timelineEntity.duration.seconds * 100)
                              .toInt();
                      i++)
                    Positioned(
                        left: i * controller.pixelPerSeconds,
                        bottom: 0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              color: const Color.fromARGB(132, 255, 255, 255),
                              height: 8,
                              width: 2,
                            ),
                            Text("$i s",
                                style: const TextStyle(
                                    color: Color.fromARGB(155, 255, 255, 255)))
                          ],
                        ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildTopbarOverlay(BuildContext context) {
    return SizedBox(
      height: topbarHeight,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: controller.leftPanelWidth,
          ),
          buildSpliter(context),
          Expanded(
            child: Listener(
              onPointerSignal: (PointerSignalEvent event) {
                if (event is PointerScrollEvent &&
                    event.kind == PointerDeviceKind.mouse) {
                  // Check if the scroll event is from a mouse device
                  double scrollDelta = event.scrollDelta.dy;
                  controller.onZoomScroll(scrollDelta);
                  // Do something with the middle mouse button scroll value (scrollDelta)
                }
              },
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  controller.onTimeHandleDrag(details);
                },
                child: Stack(
                  // fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                        child: Container(
                      color: Colors.white.withOpacity(0),
                    )),
                    ListenableBuilder(
                        listenable: controller.animationController,
                        builder: (context, _) {
                          return Positioned(
                            left: controller.time * controller.pixelPerSeconds,
                            child: handleBuilder == null
                                ? Container(
                                    color: Colors.white,
                                    height: 50,
                                    width: 5,
                                  )
                                : handleBuilder!(context),
                          );
                        })
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
