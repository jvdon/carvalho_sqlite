import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final String text;
  final IconData icon;
  final double width;
  final double spacing;
  final bool reversed;
  final double fontSize;

  const IconText({
    super.key,
    required this.icon,
    required this.text,
    this.width = 150,
    this.spacing = 10,
    this.reversed = false,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: spacing,
        children: reversed
            ? [
                Text(
                  text,
                  style: TextStyle(fontSize: fontSize),
                ),
                Icon(icon),
              ]
            : [
                Icon(icon),
                Text(
                  text,
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
      ),
    );
  }
}
