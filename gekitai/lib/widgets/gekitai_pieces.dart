import 'package:flutter/material.dart';

class GekitaiPiece extends StatelessWidget {
  final Color? color;

  const GekitaiPiece({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(width: 2.0, color: Colors.black),
      ),
    );
  }
}
