import 'package:animation_editor/src/controller.dart';
import 'package:animation_editor/src/models.dart';
import 'package:animation_editor/src/view.dart';
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
  late AnimationEditorController controller = AnimationEditorController(
      AnimationTimelineEntity(
          name: "Anim 1",
          playType: "oneShot",
          tracks: {
            "item1": Track(name: "Icon", keyframes: {
              PropertyKeyType.position.name: [
                Keyframe(
                    time: 0.01,
                    itemId: "item1",
                    propertyKey: PropertyKeyType.positionRelative.name,
                    propertyValue: {"x": 1, "y": 2},
                    curve: "linear"),
                Keyframe(
                    time: 3,
                    itemId: "item1",
                    propertyKey: PropertyKeyType.positionRelative.name,
                    propertyValue: {"x": 1, "y": 2},
                    curve: "linear")
              ],
              PropertyKeyType.scale.name: [
                Keyframe(
                    time: 0.01,
                    itemId: "item1",
                    propertyKey: PropertyKeyType.positionRelative.name,
                    propertyValue: {"x": 1, "y": 2},
                    curve: "linear"),
                Keyframe(
                    time: 3,
                    itemId: "item1",
                    propertyKey: PropertyKeyType.positionRelative.name,
                    propertyValue: {"x": 1, "y": 2},
                    curve: "linear")
              ]
            }),
            "item2": Track(name: "Text box", keyframes: {
              PropertyKeyType.scale.name: [
                Keyframe(
                    time: 0.01,
                    itemId: "item1",
                    propertyKey: PropertyKeyType.positionRelative.name,
                    propertyValue: {"x": 1, "y": 2},
                    curve: "linear"),
                Keyframe(
                    time: 3,
                    itemId: "item1",
                    propertyKey: PropertyKeyType.positionRelative.name,
                    propertyValue: {"x": 1, "y": 2},
                    curve: "linear")
              ]
            }),
            "item3": Track(name: "Text box", keyframes: {
              PropertyKeyType.scale.name: [
                Keyframe(
                    time: 0.01,
                    itemId: "item1",
                    propertyKey: PropertyKeyType.positionRelative.name,
                    propertyValue: {"x": 1, "y": 2},
                    curve: "linear"),
                Keyframe(
                    time: 3,
                    itemId: "item1",
                    propertyKey: PropertyKeyType.positionRelative.name,
                    propertyValue: {"x": 1, "y": 2},
                    curve: "linear")
              ]
            })
          },
          duration: AnimDuration(seconds: 3)),
      this);

  double height = 200;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: Column(children: [
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
                                    controller.addTrack(
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
                                    controller.addKeyframes(
                                        "${textEditingController.text}_id",
                                        textEditingController2.text, []);
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
                  child: const Text("Add keyframes")),
            ]),
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
            child: AnimationEditor(
              controller: controller,
              handleLineColor: const Color.fromARGB(255, 16, 173, 178),
              handleLineWidth: 1.5,
              valueBuilder: const {
                // PropertyKeyType.scale.name: (context, keyframe) {
                //   return Vector2ValueWidget(
                //     keyframe: keyframe,
                //   );
                // }
              },
              handleBuilder: (context) {
                return Container(
                  color: const Color.fromARGB(255, 0, 193, 193),
                  height: MediaQuery.of(context).size.height,
                  width: 4,
                );
              },
            ))
      ],
    );
  }
}
