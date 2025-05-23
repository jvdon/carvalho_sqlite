import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double width;
  final TextInputType keyboardType;
  final List<TextInputFormatter> formatters;
  final bool outline;

  const CustomInput({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.width = 150,
    this.formatters = const [],
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        label: Text(label),
        border: (outline) ? OutlineInputBorder() : UnderlineInputBorder(),
      ),
      keyboardType: keyboardType,
      controller: controller,
      inputFormatters: formatters,
    );
  }
}
