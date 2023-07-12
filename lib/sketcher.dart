import 'dart:math';

import 'package:drawing_app/drawn_line.dart';
import 'package:flutter/material.dart';
import 'package:arrow_path/arrow_path.dart';

class Sketcher extends CustomPainter {
  final List<DrawnPoint> points;
  final List<Place> places;
  final List<DrawnArc> arcs;
  final List<DrawnLabel> labels;

  Sketcher(
      {required this.points,
      required this.places,
      required this.arcs,
      required this.labels});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    for (int i = 0; i < labels.length; i++) {
      TextSpan span = new TextSpan(
          style: new TextStyle(color: Colors.black),
          text: labels[i].name.toString());
      TextPainter tp = new TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      var textLabelOffset = labels[i].offset;
      tp.paint(canvas, textLabelOffset);
    }
    for (int i = 0; i < points.length; ++i) {
      if (points[i] == null) continue;
      paint.color = points[i].color;
      paint.strokeWidth = 10;
      if (points[i].shape.contains("Transition")) {
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
      var placeRadius = 10.0;
      var tokenRadius = 4.0;
      var spacing = 0.75;
      canvas.drawCircle(places[i].point, placeRadius, paint);
      canvas.drawCircle(places[i].point, (placeRadius - 0.3 * (placeRadius)),
          paint..color = Colors.white);
      // other points where token is the main guy
      if (places[i].tokens == 1) {
        canvas.drawCircle(
            places[i].point, tokenRadius, paint..color = Colors.black);
      } else if (places[i].tokens == 2) {
        // two circle packing solution.
        canvas.drawCircle(
            Offset(places[i].point.dx - (tokenRadius / 2 + spacing),
                places[i].point.dy),
            tokenRadius / 2,
            paint..color = Colors.black);
        canvas.drawCircle(
            Offset(places[i].point.dx + (tokenRadius / 2 + spacing),
                places[i].point.dy),
            tokenRadius / 2,
            paint..color = Colors.black);
      } else if (places[i].tokens == 3) {
        // three circle packing solution.
        canvas.drawCircle(
            Offset(places[i].point.dx,
                places[i].point.dy - (tokenRadius / 2 + spacing)),
            tokenRadius / 2,
            paint..color = Colors.black);
        canvas.drawCircle(
            Offset(places[i].point.dx - (tokenRadius / 2 + spacing),
                places[i].point.dy + (tokenRadius / 2 + spacing)),
            tokenRadius / 2,
            paint..color = Colors.black);
        canvas.drawCircle(
            Offset(places[i].point.dx + (tokenRadius / 2 + spacing),
                places[i].point.dy + (tokenRadius / 2 + spacing)),
            tokenRadius / 2,
            paint..color = Colors.black);
      } else if (places[i].tokens == 4) {
        // two circle packing solution.
        canvas.drawCircle(
            Offset(places[i].point.dx - (tokenRadius / 2 + spacing),
                places[i].point.dy - (tokenRadius / 2 + spacing)),
            tokenRadius / 2,
            paint..color = Colors.black);
        canvas.drawCircle(
            Offset(places[i].point.dx + (tokenRadius / 2 + spacing),
                places[i].point.dy - (tokenRadius / 2 + spacing)),
            tokenRadius / 2,
            paint..color = Colors.black);
        canvas.drawCircle(
            Offset(places[i].point.dx + (tokenRadius / 2 + spacing),
                places[i].point.dy + (tokenRadius / 2 + spacing)),
            tokenRadius / 2,
            paint..color = Colors.black);
        canvas.drawCircle(
            Offset(places[i].point.dx - (tokenRadius / 2 + spacing),
                places[i].point.dy + (tokenRadius / 2 + spacing)),
            tokenRadius / 2,
            paint..color = Colors.black);
      } else {
        // if there is 0 tokens in the place then don't draw a label
        if (places[i].tokens != 0) {
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
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}

class DrawAllJunctions extends CustomPainter {
  final List<DrawnJunction> junctions;
  final DrawnJunction hoverJunction;

  DrawAllJunctions({required this.junctions, required this.hoverJunction});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;
    for (var i = 0; i < junctions.length; i++) {
      if (junctions[i].shape == "4-Port") {
        // draw a 4-port at point
        draw4port(junctions[i].point.dx, junctions[i].point.dy, canvas, paint);
      } else if (junctions[i].shape == "3-Port") {
        draw3port(junctions[i].point.dx, junctions[i].point.dy, canvas, paint);
      } else if (junctions[i].shape == "2-Port") {
        draw2Port(junctions[i].point.dx, junctions[i].point.dy, canvas, paint);
      }
    }
    paint.color = Colors.black45;
    if (hoverJunction.shape == "4-Port") {
      // draw a 4-port at point
      draw4port(hoverJunction.point.dx, hoverJunction.point.dy, canvas, paint);
    } else if (hoverJunction.shape == "3-Port") {
      draw3port(hoverJunction.point.dx, hoverJunction.point.dy, canvas, paint);
    } else if (hoverJunction.shape == "2-Port") {
      draw2Port(hoverJunction.point.dx, hoverJunction.point.dy, canvas, paint);
    }
  }

  @override
  bool shouldRepaint(DrawAllJunctions oldDelegate) {
    return true;
  }
}

void draw4port(double pointx, double pointy, Canvas canvas, Paint paint) {
  canvas.drawLine(Offset(pointx, pointy), Offset(pointx + 100, pointy), paint);
  canvas.drawLine(Offset(pointx, pointy), Offset(pointx - 100, pointy), paint);
  canvas.drawLine(Offset(pointx, pointy), Offset(pointx, pointy + 100), paint);
  canvas.drawLine(Offset(pointx, pointy), Offset(pointx, pointy - 100), paint);
}

void draw3port(double pointx, double pointy, Canvas canvas, Paint paint) {
  canvas.drawLine(Offset(pointx, pointy), Offset(pointx + 100, pointy), paint);
  canvas.drawLine(Offset(pointx, pointy), Offset(pointx, pointy + 100), paint);
  canvas.drawLine(Offset(pointx, pointy), Offset(pointx, pointy - 100), paint);
}

void draw2Port(double pointx, double pointy, Canvas canvas, Paint paint) {
  canvas.drawLine(Offset(pointx, pointy), Offset(pointx, pointy + 100), paint);
  canvas.drawLine(Offset(pointx, pointy), Offset(pointx, pointy - 100), paint);
}

class ArcSketcher extends CustomPainter {
  final List<DrawnArc> arcs;

  ArcSketcher({required this.arcs});

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
      // if there is a weight of 1 then there should be no label
      if (arcs[i].weight != 1) {
        // special theta to find the tangent which the label should sit on.
        var theta1 = (atan(deltaY / deltaX) + pi / 2);
        var textLabelTranslation = Offset.fromDirection(theta1, 10);
        var textLabelOffset = Offset.fromDirection(theta, distance / 2)
            .translate(arcs[i].point1.dx + textLabelTranslation.dx,
                arcs[i].point1.dy + textLabelTranslation.dy);
        tp.paint(canvas, textLabelOffset);
      }
      TextSpan xSpan =
          new TextSpan(style: new TextStyle(color: Colors.black), text: "x");
      TextPainter xpainter = new TextPainter(
          text: xSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      xpainter.layout();
      if (arcs[i].isDynamic) {
        // special theta to find the tangent which the label should sit on.
        var theta1 = (atan(deltaY / deltaX) + pi / 2);
        var textLabelTranslation = Offset.fromDirection(theta1, 10);
        var textLabelOffset = Offset.fromDirection(theta, distance / 2)
            .translate(arcs[i].point1.dx + textLabelTranslation.dx,
                arcs[i].point1.dy + textLabelTranslation.dy);
        xpainter.paint(canvas, textLabelOffset);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(ArcSketcher oldDelegate) {
    return true;
  }
}
