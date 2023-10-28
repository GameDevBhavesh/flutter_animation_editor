import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../animation_editor.dart';

Map<
    String,
    Function(AnimationEditorController controller, String trackKey,
        {bool fromCurrentHandle})> keyframesAddEntry = {
  "position:x": (controller, trackKey, {fromCurrentHandle = true}) {
    final trackAnimation = controller.getAnimation(trackKey, "position:x");
    controller.addKeyframe(
        trackKey,
        "position:x",
        Keyframe(
            time: controller.time,
            itemId: trackKey,
            propertyKey: "position:x",
            propertyValue:
                trackAnimation != null ? trackAnimation!.value : {"value": 0},
            propertyType: "double",
            curve: "linear"));
  },
  "position": (controller, trackKey, {fromCurrentHandle = true}) {
    final trackAnimation = controller.getAnimation(trackKey, "position");
    controller.addKeyframe(
        trackKey,
        "position",
        Keyframe(
            time: controller.time,
            itemId: trackKey,
            propertyKey: "position",
            propertyValue: trackAnimation != null
                ? {"x": trackAnimation.value.dx, "y": trackAnimation.value.dy}
                : {"x": 0, "y": 0},
            propertyType: "Offset",
            curve: "linear"));
  },
  "position:y": (controller, trackKey, {fromCurrentHandle = true}) {
    controller.addKeyframe(
        trackKey,
        "position:y",
        Keyframe(
            time: controller.time,
            itemId: trackKey,
            propertyKey: "position:y",
            propertyValue: {"value": 0},
            propertyType: "double",
            curve: "linear"));
  },
  "scale:x": (controller, trackKey, {fromCurrentHandle = true}) {
    controller.addKeyframe(
        trackKey,
        "scale:x",
        Keyframe(
            time: controller.time,
            itemId: trackKey,
            propertyKey: "scale:x",
            propertyValue: {"value": 0},
            propertyType: "double",
            curve: "linear"));
  },
  "scale:y": (controller, trackKey, {fromCurrentHandle = true}) {
    controller.addKeyframe(
        trackKey,
        "scale:y",
        Keyframe(
            time: controller.time,
            itemId: trackKey,
            propertyKey: "scale:y",
            propertyValue: {"value": 0},
            propertyType: "double",
            curve: "linear"));
  },
  "contrast": (controller, trackKey, {fromCurrentHandle = true}) {
    controller.addKeyframe(
        trackKey,
        "contrast",
        Keyframe(
            time: controller.time,
            itemId: trackKey,
            propertyKey: "contrast",
            propertyValue: {"value": 0},
            propertyType: "double",
            curve: "linear"));
  },
  "rotation": (controller, trackKey, {fromCurrentHandle = true}) {
    controller.addKeyframe(
        trackKey,
        "rotation",
        Keyframe(
            time: controller.time,
            itemId: trackKey,
            propertyKey: "rotation",
            propertyValue: {"value": 0},
            propertyType: "double",
            curve: "linear"));
  },
};

class AnimatorItem extends StatelessWidget {
  const AnimatorItem(
      {super.key,
      required this.controller,
      required this.child,
      required this.trackId});
  final AnimationEditorController controller;
  final Widget child;
  final String trackId;
  @override
  Widget build(BuildContext context) {
    return Listener(
      child: child,
      onPointerDown: (event) {
        if (event.kind == PointerDeviceKind.mouse &&
            event.buttons == kSecondaryMouseButton) {
          showContextMenu(context, event.position);
        }
      },
    );
  }

  showContextMenu(BuildContext context, Offset position) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final menuItem = await showMenu<String>(
        context: context,
        items: [
          const PopupMenuItem(value: "addTrack", child: Text('AddTrack')),
          for (final entry in keyframesAddEntry.entries)
            PopupMenuItem(child: Text(entry.key), value: entry.key),
        ],
        position:
            RelativeRect.fromSize(position & Size(48.0, 48.0), overlay.size));

    if (keyframesAddEntry.containsKey(menuItem)) {
      keyframesAddEntry[menuItem]!(controller, trackId);
    } else if (menuItem == "addTrack") {
      controller.addTrack(trackId, trackId);
    }
    // switch (menuItem) {
    //   case "addTrack":
    //     controller.addTrack(trackId, trackId);
    //     break;
    //   case 2:
    //     print("add pos");
    //     final pos = controller.getAnimation(trackId, "trackId");

    //     if (controller.hasKeyframes(trackId, "position")) {
    //       addPosition();
    //       print("addPosition");
    //     } else {
    //       createPosition();
    //       print("createPosition");
    //     }

    //     break;
    //   default:
    // }
  }

  createPosition() {
    final pos = controller.getAnimation(trackId, "trackId");
    controller.addKeyframes(trackId, "position", [
      Keyframe(
          time: controller.time,
          itemId: trackId,
          propertyKey: "position",
          propertyType: "Offset",
          propertyValue: pos != null
              ? {"x": pos.value.dx, "y": pos.value!.dy}
              : {"x": 0, "y": 0},
          curve: "linear")
    ]);
  }

  addPosition() {
    final pos = controller.getAnimation(trackId, "trackId");
    controller.addKeyframe(
        trackId,
        "position",
        Keyframe(
            time: controller.time,
            itemId: trackId,
            propertyKey: "position",
            propertyType: "Offset",
            propertyValue: pos != null
                ? {"x": pos.value.dx, "y": pos.value!.dy}
                : {"x": 0, "y": 0},
            curve: "linear"));
  }
}
