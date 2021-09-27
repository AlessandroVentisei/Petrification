import 'package:flutter/material.dart';

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;
  final String shape;

  DrawnLine(this.path, this.color, this.shape, this.width);
}

//DrawnPoint for places and transitions, and DrawnArc for arcs only
class DrawnPoint {
  final Offset point;
  final String shape;
  final Color color;
  DrawnPoint(this.point, this.shape, this.color);
}

class DrawnArc {
  final Offset point1;
  final Offset point2;
  final Color color;
  DrawnArc(this.point1, this.point2, this.color);
}
