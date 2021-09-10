import 'package:flutter/material.dart';

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;
  final String shape;

  DrawnLine(this.path, this.color, this.shape, this.width);
}

class Arc {
  final Offset point1;
  final Offset point2;
  final Color color;
  final double width;
  Arc(this.point1, this.point2, this.color, this.width);
}
