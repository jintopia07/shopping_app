import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String value;
  final double size;
  final FontWeight fontWeight;
  final Color color;
  const TextWidget(
      {super.key,
      required this.value,
      required this.size,
      required this.fontWeight,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(fontSize: size, fontWeight: fontWeight, color: color),
    );
  }
}
