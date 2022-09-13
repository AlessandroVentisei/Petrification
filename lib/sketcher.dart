import 'dart:math';
import 'dart:ui';

import 'package:drawing_app/drawn_line.dart';
import 'package:flutter/material.dart';
import 'package:arrow_path/arrow_path.dart';

class Sketcher extends CustomPainter {
  final List<DrawnPoint> points;
  final List<Place> places;
  final List<DrawnArc> arcs;

  Sketcher({this.points, this.places, this.arcs});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    for (int i = 0; i < points.length; ++i) {
      if (points[i] == null) continue;
      paint.color = points[i].color;
      paint.strokeWidth = 10;
      if (points[i].shape == "Transition") {
        canvas.drawRect(points[i].point - Offset(10, 10) & Size(20, 20), paint);
        canvas.drawRect(
            points[i].point - Offset(10, 10) + Offset(2.5, 2.5) & Size(15, 15),
            paint..color = Colors.white);
      }
    }
    for (int i = 0; i < places.length; ++i) {
      if (places[i] == null) continue;
      paint.color = places[i].color;
      paint.strokeWidth = 10;
      canvas.drawCircle(places[i].point, 10, paint);
      canvas.drawCircle(
          places[i].point, (10 - 0.3 * (10)), paint..color = Colors.white);
      // other points where token is the main guy
      if (places[i].tokens == 1) {
        canvas.drawCircle(places[i].point, 4, paint..color = Colors.black);
      } else {
        TextSpan span = new TextSpan(
            style: new TextStyle(color: Colors.black),
            text: places[i].tokens.toString());
        TextPainter tp = new TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, (places[i].point + Offset(-5, -25)));
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}

class ArcSketcher extends CustomPainter {
  final List<DrawnArc> arcs;

  ArcSketcher({this.arcs});

  @override
  void paint(Canvas canvas, Size size) {
    Path path;
    Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;
    for (int i = 0; i < arcs.length; ++i) {
      if (arcs[i] == null) continue;
      if (arcs[i].point1 == Offset(0, 0) || arcs[i].point2 == Offset(0, 0))
        continue;
      path = Path();
      // path.addPolygon([arcs[i].point1, arcs[i].point2], false);

      var deltaX = arcs[i].point2.dx - arcs[i].point1.dx;
      var deltaY = arcs[i].point2.dy - arcs[i].point1.dy;
      var theta = atan2(deltaY, deltaX);
      // find starting offset with ten pixels in the direction of the angle of the arc.
      var startOffset = Offset.fromDirection(theta, 10)
          .translate(arcs[i].point1.dx, arcs[i].point1.dy);
      // move to this point.
      path.moveTo(startOffset.dx, startOffset.dy);
      var distance = sqrt(pow(deltaX, 2) + pow(deltaY, 2));
      // find ending offset with (distance - 10 pixels) in the direction of the angle of the arc.
      var lineTo = Offset.fromDirection(theta, distance - 10)
          .translate(arcs[i].point1.dx, arcs[i].point1.dy);
      // move to that point.
      path.lineTo(lineTo.dx, lineTo.dy);
      path = ArrowPath.make(path: path, tipLength: 5);
      TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.black),
          text: arcs[i].weight.toString());
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      // special theta to find the tangent which the label should sit on.
      var theta1 = (atan(deltaY / deltaX) + pi / 2);
      var textLabelTranslation = Offset.fromDirection(theta1, 10);
      var textLabelOffset = Offset.fromDirection(theta, distance / 2).translate(
          arcs[i].point1.dx + textLabelTranslation.dx,
          arcs[i].point1.dy + textLabelTranslation.dy);
      tp.paint(canvas, textLabelOffset);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ArcSketcher oldDelegate) {
    return true;
  }
}
