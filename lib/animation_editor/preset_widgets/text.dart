import 'package:animation_editor/animation_editor.dart';
import 'package:flutter/material.dart';

class KeyframedText extends StatelessWidget {
  const KeyframedText(this.data, {super.key, this.style, this.percent = 1});

  final String data;

  ///
  /// [@var		final	double]
  /// range between 1-0 as percentage how much text shown on screen
  /// 1.0 means full text.
  /// 0.0 means empty text.
  ///
  final double percent;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      data.substring(
          0, (data.length * context.readAnim("percent", percent)).ceil()),
      style: context.readAnim("style", style),
    );
  }
}
