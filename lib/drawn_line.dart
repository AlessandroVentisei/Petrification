import 'package:flutter/material.dart';

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
