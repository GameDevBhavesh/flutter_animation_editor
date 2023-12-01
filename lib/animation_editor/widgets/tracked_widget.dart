import 'dart:ui';

import 'package:animation_editor/animation_editor/controllers/object_track_controller.dart';
import 'package:animation_editor/animation_editor/controllers/tracked_anim_controller.dart';
import 'package:animation_editor/animation_editor/state_magment/controller_query.dart';
import 'package:flutter/gestures.dart';

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

// class ContextMenuRegion extends StatelessWidget {
//   const ContextMenuRegion(
//       {super.key, required this.child, this.items = const []});
//   final Widget child;
//   final List<PopupMenuItem> items;

//   @override
//   Widget build(BuildContext context) {
//     return Listener(
//         child: child,
//         onPointerDown: (event) {
//           if (event.kind == PointerDeviceKind.mouse &&
//               event.buttons == kSecondaryMouseButton) {
//             showContextMenu(context, event.position, items);
//           }
//         });
//   }

//   static void showContextMenu(
//       BuildContext context, Offset atPosition, List<PopupMenuItem> items) {
//     final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
//     showMenu(
//         context: context,
//         position: RelativeRect.fromSize(
//             atPosition & const Size(48.0, 48.0), overlay.size),
//         items: items);
//   }
// }
