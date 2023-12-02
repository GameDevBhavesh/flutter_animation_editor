import 'dart:convert';

import 'package:animation_editor/animation_editor/controllers/object_track_controller.dart';
import 'package:animation_editor/animation_editor/controllers/tracked_anim_controller.dart';
import 'package:animation_editor/animation_editor/widgets/object_track_view.dart';
// import 'package:animation_editor/src/widgets/map_editor.dart';
// import 'package:animation_editor/src/widgets/track_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'models/models.dart';

class ContextMenuOptions<OptionType, ControllerType> {
  ContextMenuOptions({required this.onSelect, this.items});
  final List<PopupMenuItem<OptionType>>? items;
  final Function(ControllerType controller, OptionType option) onSelect;
}

class TrackedAnimationEditor extends StatelessWidget {
  const TrackedAnimationEditor(
      {super.key,
      required this.controller,
      this.handleBuilder,
      this.tracksHeight = 35,
      this.handleLineWidth = .5,
      this.valueBuilder,
      this.handleLineColor = Colors.white,
      required this.contextMenu});
  final TrackedAnimationController controller;
  final ContextMenuOptions<int, ObjectTrackController> contextMenu;
  final Widget Function(BuildContext context)? handleBuilder;

  final double handleLineWidth;
  final Color handleLineColor;
  static TextStyle style = const TextStyle(color: Colors.white);

  static double topbarHeight = 45;
  final double tracksHeight;
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
                    controller.changePlayhead(details);
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
    return RepaintBoundary(
      child: ListenableBuilder(
          listenable: Listenable.merge(
            [],
          ),
          builder: (context, c) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final track
                    in controller.trackedAnimation.objectTracks.entries)
                  ObjectTrackView(
                    height: tracksHeight,
                    onExpand: () {
                      controller
                          .readChildController(track.key)!
                          .toggleCollapse();
                    },
                    splitViewBuilder: buildSpliter,
                    controller: controller.readChildController(track.key)!,
                  )
              ],
            );
          }),
    );
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
            width: controller.context.leftPanelWidth,
            color: const Color.fromARGB(0, 20, 20, 20),
            constraints: const BoxConstraints(minWidth: 280),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      controller.playPause();
                    },
                    icon: Icon(
                        controller.context.animationController.isAnimating
                            ? Icons.pause_sharp
                            : Icons.play_arrow_outlined,
                        size: 30,
                        color: Colors.white)),
                DropdownButton<String>(
                    style: const TextStyle(color: Colors.white),
                    value: controller.playMode,
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
                      controller.changePlaymode(val!);
                    }),
                SizedBox(
                    width: 60,
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: controller.durationTextController,
                      onSubmitted: (value) {
                        controller.changeDuration(
                            Duration(seconds: int.parse(value)));
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
                          (controller.trackedAnimation.duration.inSeconds * 100)
                              .toInt();
                      i++)
                    Positioned(
                        left: i * controller.context.pixelPerSeconds,
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
          Container(
            constraints: const BoxConstraints(minWidth: 280),
            width: controller.context.leftPanelWidth,
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
                }
              },
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  controller.changePlayhead(details);
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                        child: Container(
                      color: Colors.white.withOpacity(0),
                    )),
                    ListenableBuilder(
                        listenable: controller.context.animationController,
                        builder: (context, _) {
                          return Positioned(
                            left: controller.context.handlePos,
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
