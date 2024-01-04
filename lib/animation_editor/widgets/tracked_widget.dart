import 'package:animation_editor/animation_editor/controllers/object_track_controller.dart';
import 'package:animation_editor/animation_editor/controllers/tracked_anim_controller.dart';

import 'package:flutter/material.dart';
import 'package:state_managment/state_magment.dart';

class TrackedWidget extends StatelessWidget {
  const TrackedWidget(
      {super.key,
      required this.id,
      required this.builder,
      this.isAnimating = true});
  final String id;
  final Widget Function(BuildContext context) builder;
  final bool isAnimating;
  @override
  Widget build(BuildContext context) {
    final editor = ControllerQuery.of<TrackedAnimationController>(context);
    if (editor != null && isAnimating) {
      final objController = editor.readChildController(id)!;
      if (objController == null) {
        return ControllerQuery<ObjectTrackController>(
            controller: objController,
            child: ListenableBuilder(
              listenable: editor.context.animationController,
              builder: (context, _) {
                return builder(context);
              },
            ));
      }
    }
    return builder(context);
  }
}
