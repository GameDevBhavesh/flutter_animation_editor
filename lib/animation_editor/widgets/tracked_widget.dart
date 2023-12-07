import 'package:animation_editor/animation_editor/controllers/object_track_controller.dart';
import 'package:animation_editor/animation_editor/controllers/tracked_anim_controller.dart';
import 'package:animation_editor/animation_editor/state_magment/controller_query.dart';
import 'package:flutter/material.dart';

class TrackedWidget extends StatelessWidget {
  const TrackedWidget(
      {super.key, required this.id, required this.builder, this.controller});
  final String id;

  final ObjectTrackController? controller;
  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    final editor = ControllerQuery.of<TrackedAnimationController>(context);
    if (editor != null) {
      return ControllerQuery<ObjectTrackController>(
          controller: controller ?? editor.readChildController(id),
          child: ListenableBuilder(
            listenable: editor.context.animationController,
            builder: (context, _) {
              return builder(context);
            },
          ));
    }
    return builder(context);
  }
}
