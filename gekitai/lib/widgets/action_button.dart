import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final Function callBack;
  final Color textColor;
  final String label;

  const ActionButton({
    super.key,
    required this.callBack,
    required this.textColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => callBack(),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
