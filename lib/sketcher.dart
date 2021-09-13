import 'dart:ui';

import 'package:drawing_app/drawn_line.dart';
import 'package:flutter/material.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;

  Sketcher({this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    for (int i = 0; i < lines.length; ++i) {
      if (lines[i] == null) continue;
      paint.color = lines[i].color;
      paint.strokeWidth = lines[i].width;
      if (lines[i].shape == "Place") {
        canvas.drawCircle(lines[i].path[0], lines[i].width, paint);
        canvas.drawCircle(
            lines[i].path[0],
            (lines[i].width - 0.3 * (lines[i].width)),
            paint..color = Colors.white);
      }
      if (lines[i].shape == "Transition") {
        canvas.drawRect(
            lines[i].path[0] - Offset(7.5, 7.5) & Size(15, 15), paint);
        canvas.drawRect(
            lines[i].path[0] - Offset(7.5, 7.5) + Offset(2.5, 2.5) &
                Size(10, 10),
            paint..color = Colors.white);
      }
      if (lines[i].shape == "Arc") {
        canvas.drawLine(lines[i].path[0], lines[i].path[1], paint);
        canvas.drawPoints(
            PointMode.polygon,
            [
              lines[i].path[1],
              lines[i].path[1] + Offset(0, 10),
              lines[i].path[1] + Offset(20, 0),
              lines[i].path[1] + Offset(0, -10),
              lines[i].path[1],
            ],
            paint);
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
