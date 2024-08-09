import 'package:flutter/material.dart';
import '/screens/components/widget_color.dart';


class CustomInputField extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final int minLines;
  final int maxLines;

  CustomInputField({
    this.isPassword = false,
    required this.hintText,
    required this.initialValue,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
    this.validator,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      validator: widget.validator,
      obscureText: widget.isPassword,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: themeColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: themeColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: themeColor,
          ),
        ),
        ),
      //),
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      cursorColor:themeColor,
      keyboardType: TextInputType.multiline,
      onChanged: (value) {
        widget.onChanged(value);
      },
    );
  }
}
