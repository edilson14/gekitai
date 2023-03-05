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

class CherryBlossomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.3, size.height * 0.4)
      ..lineTo(size.width * 0.4, size.height * 0.6)
      ..lineTo(size.width * 0.2, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height * 0.8)
      ..lineTo(size.width * 0.3, size.height * 1)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width * 0.7, size.height * 1)
      ..lineTo(size.width * 0.6, size.height * 0.8)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..lineTo(size.width * 0.6, size.height * 0.6)
      ..lineTo(size.width * 0.7, size.height * 0.4)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
