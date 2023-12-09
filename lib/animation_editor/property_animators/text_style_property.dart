import 'package:flutter/widgets.dart';

import '../controllers/property_track_controller.dart';

import 'property.dart';

class TextStyleProperty extends AnimationProperty<TextStyle> {
  const TextStyleProperty();

  @override
  TextStyle lerp(TextStyle a, TextStyle b, double t) {
    if (t == 0) {
      return a;
    }
    if (t == 1) {
      return b;
    }
    return TextStyle.lerp(a, b, t)!;
  }

  TextDecoration getTextDecorationFromString(String value) {
    switch (value.toLowerCase()) {
      case 'none':
        return TextDecoration.none;
      case 'underline':
        return TextDecoration.underline;
      case 'overline':
        return TextDecoration.overline;
      case 'lineThrough':
        return TextDecoration.lineThrough;
      default:
        throw ArgumentError('Invalid TextDecoration value: $value');
    }
  }

  @override
  TextStyle fromJson(json) {
    return TextStyle(
      fontFamily: json['fontFamily'],
      fontSize: json['fontSize'],
      color: Color(json['color']),
      fontWeight: FontWeight.values[json['fontWeight']],
      fontStyle: FontStyle.values[json['fontStyle']],
      letterSpacing: json['letterSpacing'],
      wordSpacing: json['wordSpacing'],
      decoration: TextDecoration.combine((json['decoration'])),
      decorationColor: Color(json['decorationColor']),
      decorationStyle: TextDecorationStyle.values[json['decorationStyle']],
    );
  }

  @override
  Map toJson(TextStyle value) {
    return {
      'fontFamily': value.fontFamily,
      'fontSize': value.fontSize,
      'color': value.color?.value,
      'fontWeight': value.fontWeight?.index,
      'fontStyle': value.fontStyle,
      'letterSpacing': value.letterSpacing,
      'wordSpacing': value.wordSpacing,
      'decoration': value.decoration,
      'decorationColor': value.decorationColor?.value,
      'decorationStyle': value.decorationStyle?.index,
    };
  }

  @override
  Widget buildInpector(
      BuildContext context, PropertyTrackController controller) {
    final anim = controller.getAnimation();
    if (anim == null) return const SizedBox();

    final val = (anim!.value as TextStyle);
    return Text("${val.fontSize}");
  }
}
