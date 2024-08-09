import 'package:flutter/material.dart';
import '/screens/components/widget_color.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final bool isEnabled;

  CustomButton({
    required this.text,
    required this.onPressed,
    this.backgroundColor = themeColor,
    this.textColor = messageColor,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(text),
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return disebleColor; // 無効なときの色
            }
            return themeColor; // 有効なときの色
          },
        ),
        foregroundColor: WidgetStateProperty.all<Color>(
          isEnabled ? messageColor : messageColor, // テキストの色も調整
        ),
      ),
    );
  }
}
