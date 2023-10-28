import 'package:animation_editor/src/keyframe_sequence.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ObjectTrack {
  String id = "object1_id";
  String name = "object1";
  Map<String, PropetryTrack> tracks = {
    "Position": OffsetTrack()
      ..name = "Position"
      ..type = "Offset"
      ..keyframes = []
  };
}

class GroupedTrack {
  String name = "transfrom";
  bool isDefault = true;
  List<PropetryTrack> tracks = [];
}

abstract class PropetryTrack<T> {
  String name = "Position";
  String type = "Offset";
  List<KeyframeItem<T>> keyframes = [];
  Widget buildInspect();
  toJson();
  PropetryTrack.fromJson();
}

class OffsetTrack extends PropetryTrack {
  const OffsetTrack(this.group, this.keyframes);
  String group = "Trasnfrom";
  @override
  String name = "Position";
  @override
  String type = "Offset";

  OffsetController controller = OffsetController(raw: {"x": 0, "y": 0});

  List<KeyframeItem> keyframes = [
    KeyframeItem(time: 0, value: const Offset(0, 0))
  ];

  OffsetTrack.fromJson() : super.fromJson();

  @override
  Widget buildInspect() {
    return ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return Row(
            children: [
              Text(controller.xController.text),
              Text(controller.yController.text)
            ],
          );
        });
  }

  @override
  toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

enum PropertyType { offset, double, int, vector3 }

Map<PropertyType, Widget Function(Animation<dynamic> anim)>
    animationInspectBuilder = {
  //   PropertyType.offset: (anim) {

  // }
};

abstract class IValueController extends ChangeNotifier {
  set(Object val);
  Object get();
}

class OffsetController extends ChangeNotifier implements IValueController {
  OffsetController({required this.raw}) {
    _value = Offset(raw["x"], raw["y"].toDouble());
  }

  final TextEditingController xController = TextEditingController(text: "0");
  final TextEditingController yController = TextEditingController(text: "0");

  final Map<String, dynamic> raw;
  Offset? _value;

  @override
  Offset get() {
    return _value!;
  }

  @override
  set(val) {
    xController.text = _value!.dx.toString();
    yController.text = _value!.dy.toString();
    notifyListeners();
    _value = val as Offset;
  }
}

class DoubleController extends ChangeNotifier implements IValueController {
  DoubleController({required this.raw}) {
    value = raw["value"].toDouble();
  }
  final TextEditingController controller = TextEditingController(text: "0");
  final Map<String, dynamic> raw;
  double? _value;
  double get value => _value ?? 0.0;

  set value(double value) {
    _value = value;
    controller.text = value.toString();
    notifyListeners();
  }

  @override
  double get() {
    return _value!;
  }

  @override
  set(val) {
    controller.text = _value.toString();
    notifyListeners();
    _value = (val as double);
  }
}
