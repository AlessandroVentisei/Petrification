import 'package:flutter/material.dart';

//DrawnPoint for places and transitions, and DrawnArc for arcs only
class DrawnPoint {
  final Offset point;
  final String shape;
  final Color color;
  DrawnPoint(this.point, this.shape, this.color);
  Map toJson(DrawnPoint value) =>
      {"point": value.point, "shape": value.shape, "color": value.color};
}

class Place {
  final Offset point;
  num tokens;
  final Color color;
  Place(this.point, this.tokens, this.color);
}

class DrawnArc {
  final Offset point1;
  final Offset point2;
  final num weight;
  final Color color;
  DrawnArc(this.point1, this.point2, this.color, this.weight);
}
