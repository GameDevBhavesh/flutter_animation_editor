import 'package:flutter/material.dart';

class KeyframeRowLeading extends StatelessWidget {
  const KeyframeRowLeading(
      {super.key,
      required this.titleText,
      required this.style,
      this.child,
      this.width = 200});

  final String titleText;
  final TextStyle style;
  final Widget? child;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: const Color.fromARGB(255, 40, 40, 40).withOpacity(0),
      width: width,
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titleText,
            style: style,
          ),
          if (child != null) child!
        ],
      ),
    );
  }
}
