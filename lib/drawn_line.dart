import 'package:flutter/material.dart';

//DrawnPoint for places and transitions, and DrawnArc for arcs only
class DrawnPoint {
  late Offset point;
  late String shape;
  late Color color;
  DrawnPoint(this.point, this.shape, this.color);
  Map<String, dynamic> toJson() {
    return {
      'point': point.dx.toString() + "," + point.dy.toString(),
      'shape': shape,
      'color': color.value.toString()
    };
  }

  DrawnPoint.fromJson(json) {
    var dxdy = json['point'].split(",");
    point = Offset(double.parse(dxdy[0]), double.parse(dxdy[1]));
    shape = json['shape'];
    color = Color(num.parse(json['color']).toInt());
  }
}

class Place {
  late Offset point;
  late num tokens;
  late Color color;
  Place(this.point, this.tokens, this.color);
  Map<String, dynamic> toJson() {
    return {
      'point': point.dx.toString() + "," + point.dy.toString(),
      'tokens': tokens.toString(),
      'color': color.value.toString()
    };
  }

  Place.fromJson(json) {
    var dxdy = json['point'].split(",");
    point = Offset(double.parse(dxdy[0]), double.parse(dxdy[1]));
    tokens = num.parse(json['tokens']);
    color = Color(num.parse(json['color']).toInt());
  }
}

class DrawnArc {
  late Offset point1;
  late Offset point2;
  late num weight;
  late Color color;
  late bool isDynamic;
  DrawnArc(this.point1, this.point2, this.color, this.weight,
      {this.isDynamic = false});
  Map<String, dynamic> toJson() {
    return {
      'point1': point1.dx.toString() + "," + point1.dy.toString(),
      'point2': point2.dx.toString() + "," + point2.dy.toString(),
      'weight': weight.toString(),
      'color': color.value.toString(),
      'isDynamic': isDynamic.toString()
    };
  }

  DrawnArc.fromJson(json) {
    var dxdy1 = json['point1'].split(",");
    var dxdy2 = json['point2'].split(",");
    point1 = Offset(double.parse(dxdy1[0]), double.parse(dxdy1[1]));
    point2 = Offset(double.parse(dxdy2[0]), double.parse(dxdy2[1]));
    weight = num.parse(json['weight']);
    color = Color(num.parse(json['color']).toInt());
  }
}

class DrawnJunction {
  late Offset point; // offset of where it has been drawn.
  late String shape; // the selected shape.
  late String serial; // when was it drawn.
  late List<JunctionConnection>
      junctionConnections; // a list of the other drawnJunctions it has been connected to.
  DrawnJunction(this.point, this.shape, this.serial,
      {required this.junctionConnections});
}

class DrawnLabel {
  late Offset offset;
  late String name;
  DrawnLabel(this.offset, this.name);
  Map<String, dynamic> toJson() {
    return {
      'offset': offset.dx.toString() + "," + offset.dy.toString(),
      'name': name,
    };
  }

  DrawnLabel.fromJson(json) {
    var dxdy = json['offset'].split(",");
    offset = Offset(double.parse(dxdy[0]), double.parse(dxdy[1]));
    name = json['name'];
  }
}

class JunctionConnection {
  String junction; // serial of the junction being connected to...
  int outPort; // the port that is being connected from.
  int inPort; // the port that is being connected to.
  JunctionConnection(this.junction, this.outPort, this.inPort);
}
