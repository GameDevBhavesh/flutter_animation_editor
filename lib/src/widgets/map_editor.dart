import 'package:flutter/material.dart';

class MapEditor<T> extends StatefulWidget {
  const MapEditor(
      {super.key,
      required this.map,
      required this.onValueSubmit,
      this.direction = Axis.vertical});
  final Map<String, T> map;
  final Function(String key, T value, Type type) onValueSubmit;
  final Axis direction;
  @override
  State<MapEditor> createState() => _MapEditorState();
}

class _MapEditorState extends State<MapEditor> {
  late Map<String, TextEditingController> controllers = {};
  static TextStyle title = TextStyle(color: Colors.white);
  @override
  void initState() {
    for (var entry in widget.map.entries) {
      controllers.putIfAbsent(
          entry.key, () => TextEditingController(text: entry.value.toString()));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final childs = [
      for (final entry in widget.map.entries) ...[
        Row(
          children: [
            Container(
              width: 100,
              child: TextField(
                  decoration: InputDecoration(
                    labelStyle: title,
                    labelText: entry.key,
                  ),
                  controller: controllers[entry.key],
                  style: title,
                  onSubmitted: (val) {
                    if (entry.value.runtimeType == String) {
                      // widget.map[entry.key] = val;
                      widget.onValueSubmit!(entry.key, val, String);
                    } else if (entry.value.runtimeType == double) {
                      widget.onValueSubmit!(entry.key, val, double);
                      // widget.map[entry.key] = double.parse(val);
                      // print(widget.map[entry.key]);
                    } else if (entry.value.runtimeType == int) {
                      widget.onValueSubmit!(entry.key, val, int);
                      // widget.map[entry.key] = double.parse(val);
                      // print(widget.map[entry.key]);
                    }
                  }),
            )
          ],
        )
      ]
    ];
    if (widget.direction == Axis.vertical) {
      return Column(
        children: childs,
      );
    }
    return Row(children: childs);
  }
}
