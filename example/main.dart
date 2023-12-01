// import 'package:animation_editor/src/controller.dart';
// import 'package:animation_editor/src/models.dart';
// import 'package:animation_editor/src/view.dart';

import 'package:animation_editor/animation_editor.dart';
import 'package:animation_editor/animation_editor/preset_widgets/container.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AnimationEditorPage(),
    );
  }
}

class AnimationEditorPage extends StatefulWidget {
  const AnimationEditorPage({super.key});

  @override
  State<AnimationEditorPage> createState() => _AnimationEditorPageState();
}

class _AnimationEditorPageState extends State<AnimationEditorPage>
    with SingleTickerProviderStateMixin {
  TextEditingController textEditingController =
      TextEditingController(text: "11");
  TextEditingController textEditingController2 =
      TextEditingController(text: "position");
  late TrackedAnimationController controller;

  double height = 200;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    controller = TrackedAnimationController(
        TrackedAnimation(
            name: "Anim 1",
            objectTracks: {
              "item1": ObjectTrack(
                  name: "item1",
                  tracks: {
                    "x": PropertyTrack(
                        objectTrackKey: "item1",
                        key: "x",
                        name: "X",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(.38, .13, .42, .32),
                              time: 0.01,
                              objectKey: 'item1',
                              trackKey: 'x',
                              value: 0),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: 'item1',
                              trackKey: 'x',
                              value: 500),
                        ]),
                    "y": PropertyTrack(
                        objectTrackKey: "item1",
                        key: "y",
                        name: "Y",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 0.01,
                              objectKey: '',
                              trackKey: '',
                              value: 0),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: '',
                              trackKey: '',
                              value: 350),
                        ]),
                    "color": PropertyTrack(
                        objectTrackKey: "item1",
                        key: "color",
                        name: "Color",
                        group: "Style",
                        dataType: "color",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 0.01,
                              objectKey: '',
                              trackKey: '',
                              value: Color.fromARGB(255, 255, 255, 255)),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: '',
                              trackKey: '',
                              value: Color.fromARGB(255, 0, 60, 255)),
                        ]),
                    "width": PropertyTrack(
                        objectTrackKey: "item1",
                        key: "width",
                        name: "width",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(.38, .13, .42, .32),
                              time: 0.01,
                              objectKey: 'item1',
                              trackKey: 'width',
                              value: 200),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: 'item1',
                              trackKey: 'width',
                              value: 300),
                        ]),
                    "rotation": PropertyTrack(
                        objectTrackKey: "item1",
                        key: "rotation",
                        name: "rotation",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(.38, .13, .42, .32),
                              time: 0.01,
                              objectKey: 'item1',
                              trackKey: 'rotation',
                              value: 0),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: 'item1',
                              trackKey: 'rotation',
                              value: 6.283185307179586),
                        ]),
                  },
                  isCollapsed: false),
              "item2": ObjectTrack(
                  name: "item2",
                  tracks: {
                    "x": PropertyTrack(
                        objectTrackKey: "item2",
                        key: "x",
                        name: "X",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(.38, .13, .42, .32),
                              time: 0.01,
                              objectKey: 'item2',
                              trackKey: 'x',
                              value: 0),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: 'item2',
                              trackKey: 'x',
                              value: 500),
                        ]),
                    "y": PropertyTrack(
                        objectTrackKey: "item2",
                        key: "y",
                        name: "Y",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 0.01,
                              objectKey: '',
                              trackKey: '',
                              value: 0),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: '',
                              trackKey: '',
                              value: 350),
                        ]),
                    "color": PropertyTrack(
                        objectTrackKey: "item2",
                        key: "color",
                        name: "Color",
                        group: "Style",
                        dataType: "color",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 0.01,
                              objectKey: '',
                              trackKey: '',
                              value: Color.fromARGB(255, 255, 255, 255)),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: '',
                              trackKey: '',
                              value: Color.fromARGB(255, 0, 60, 255)),
                        ]),
                    "width": PropertyTrack(
                        objectTrackKey: "item2",
                        key: "width",
                        name: "width",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(.38, .13, .42, .32),
                              time: 0.01,
                              objectKey: 'item2',
                              trackKey: 'width',
                              value: 200),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: 'item2',
                              trackKey: 'width',
                              value: 300),
                        ]),
                    "rotation": PropertyTrack(
                        objectTrackKey: "item2",
                        key: "rotation",
                        name: "rotation",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(.38, .13, .42, .32),
                              time: 0.01,
                              objectKey: 'item2',
                              trackKey: 'rotation',
                              value: 0),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: 'item2',
                              trackKey: 'rotation',
                              value: 6.283185307179586),
                        ]),
                  },
                  isCollapsed: false),
              "item3": ObjectTrack(
                  name: "item3",
                  tracks: {
                    "x": PropertyTrack(
                        objectTrackKey: "item3",
                        key: "x",
                        name: "X",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(.38, .13, .42, .32),
                              time: 0.01,
                              objectKey: 'item3',
                              trackKey: 'x',
                              value: 0),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: 'item3',
                              trackKey: 'x',
                              value: 500),
                        ]),
                    "y": PropertyTrack(
                        objectTrackKey: "item3",
                        key: "y",
                        name: "Y",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 0.01,
                              objectKey: '',
                              trackKey: '',
                              value: 0),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: '',
                              trackKey: '',
                              value: 350),
                        ]),
                    "color": PropertyTrack(
                        objectTrackKey: "item3",
                        key: "color",
                        name: "Color",
                        group: "Style",
                        dataType: "color",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 0.01,
                              objectKey: '',
                              trackKey: '',
                              value: Color.fromARGB(255, 255, 255, 255)),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: '',
                              trackKey: '',
                              value: Color.fromARGB(255, 0, 60, 255)),
                        ]),
                    "width": PropertyTrack(
                        objectTrackKey: "item3",
                        key: "width",
                        name: "width",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(.38, .13, .42, .32),
                              time: 0.01,
                              objectKey: 'item3',
                              trackKey: 'width',
                              value: 200),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: 'item3',
                              trackKey: 'width',
                              value: 300),
                        ]),
                    "rotation": PropertyTrack(
                        objectTrackKey: "item3",
                        key: "rotation",
                        name: "rotation",
                        group: "transfrom",
                        dataType: "double",
                        keyframes: [
                          Keyframe(
                              curve: const Cubic(.38, .13, .42, .32),
                              time: 0.01,
                              objectKey: 'item3',
                              trackKey: 'rotation',
                              value: 0),
                          Keyframe(
                              curve: const Cubic(0, 0, 1, 1),
                              time: 2,
                              objectKey: 'item3',
                              trackKey: 'rotation',
                              value: 6.283185307179586),
                        ]),
                  },
                  isCollapsed: false),
            },
            duration: const Duration(seconds: 5)),
        this,
        configuration: AnimationEditorConfiguration.defaults());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Column(
              children: [
                Column(children: [
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: textEditingController,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        controller.addObjectTrack(
                                            "${textEditingController.text}_id",
                                            textEditingController.text);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text("Add track")),
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: textEditingController,
                                    ),
                                    TextFormField(
                                      controller: textEditingController2,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // controller.ad(
                                        //     "${textEditingController.text}_id",
                                        //     textEditingController2.text, []);
                                        // Navigator.pop(context);
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text("Add keyframes")),
                ]),
                Expanded(
                  child: ControllerQuery(
                    controller: controller,
                    child: Stack(
                      children: [
                        for (final object
                            in controller.trackedAnimation.objectTracks.entries)
                          TrackedWidget(
                            id: object.key,
                            builder: (context) {
                              final track =
                                  ControllerQuery.of<ObjectTrackController>(
                                      context);
                              track!.readChildController("x")!.getAnimation();

                              return Positioned(
                                left: context.readAnim("x", 100.0),
                                top: context.readAnim("y", 100.0),
                                child: Transform.rotate(
                                  angle: context.readAnim("angle", 0),
                                  child: KeyframedContainer(
                                    height: 100,
                                    width: 200,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        MouseRegion(
            cursor: SystemMouseCursors.resizeUp,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {},
              onVerticalDragUpdate: (details) {
                setState(() {
                  height -= details.delta.dy;
                });
              },
              child: Container(
                height: 10,
                color: const Color.fromARGB(24, 255, 255, 255),
              ),
            )),
        Container(
            constraints: const BoxConstraints(minHeight: 200),
            height: height,
            child: TrackedAnimationEditor(
              contextMenu: ContextMenuOptions(
                  items: [],
                  onSelect: (trackController, value) {
                    switch (value) {
                      case 0:
                        showAboutDialog(context: context);
                        break;
                      default:
                    }
                  }),
              controller: controller,
              handleLineColor: const Color.fromARGB(255, 16, 173, 178),
              handleLineWidth: 1.5,
              handleBuilder: (context) {
                return Container(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  height: MediaQuery.of(context).size.height,
                  width: 4,
                );
              },
            ))
      ],
    );
  }
}
