import 'package:drawing_app/currentMarking.dart';
import 'package:flutter/material.dart';
import './sketcher.dart';
import './drawn_line.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:matrix2d/matrix2d.dart';
import './difference_matrix_builder.dart';

class Building extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BuildingState();
  }
}

class BuildingState extends State<Building> {
  List<DrawnPoint> drawnPoints = <DrawnPoint>[];
  List<DrawnArc> drawnArcs = <DrawnArc>[];
  Map<String, dynamic> matrices = {"Place": 0, "Transition": 0};
  DrawnArc currentArc;
  Color selectedColor = Colors.black;
  String selectedShape;
  List<dynamic> currentMarking;
  List<dynamic> currentDiffMatrix;
  Matrix2d m2d = Matrix2d();

  StreamController<List<DrawnPoint>> drawnPointsStreamController =
      StreamController<List<DrawnPoint>>.broadcast();
  StreamController<List<DrawnArc>> drawnArcsStreamController =
      StreamController<List<DrawnArc>>.broadcast();
  StreamController<DrawnArc> currentArcStreamController =
      StreamController<DrawnArc>.broadcast();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          buildAllPoints(context),
          buildAllArcs(context),
          buildCurrentArc(context),
          buildShapeToolbar(),
        ],
      ),
    );
  }

  Widget buildCurrentArc(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onTapDown: onTap,
      child: RepaintBoundary(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnArc>(
              stream: currentArcStreamController.stream,
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: ArcSketcher(
                    arcs: [currentArc],
                  ),
                );
              }),
        ),
      ),
    );
  }

  Widget buildAllArcs(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        padding: EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<DrawnArc>>(
          stream: drawnArcsStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: ArcSketcher(
                arcs: drawnArcs,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildAllPoints(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        padding: EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<DrawnPoint>>(
          stream: drawnPointsStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                points: drawnPoints,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildShapeToolbar() {
    return Positioned(
      top: 40.0,
      left: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Divider(
            height: 20.0,
          ),
          buildShapeButton("Place"),
          buildShapeButton("Transition"),
          buildShapeButton("Arc"),
          buildShapeButton("Token"),
          buildShapeButton("Delete"),
        ],
      ),
    );
  }

  Widget buildShapeButton(String string) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: false,
        backgroundColor: Colors.black,
        child: Container(
          child: Text(string, style: TextStyle(fontSize: 8)),
        ),
        onPressed: () {
          setState(() {
            selectedShape = string;
          });
        },
      ),
    );
  }

  void onPanStart(details) {
    RenderBox box = context.findRenderObject();
    Offset point = box.globalToLocal(details.globalPosition);
    point = (point ~/ 25) * 25;
    if (selectedShape == "Arc") {
      if (conflictTesting(point, drawnPoints) != "freeSpace") {
        currentArc = DrawnArc(point, point + Offset(5, 5), selectedColor);
        currentArcStreamController.add(currentArc);
      } else {
        currentArc = DrawnArc(Offset(0, 0), Offset(0, 0), selectedColor);
        return;
      }
    }
    if (selectedShape == "Place" || selectedShape == "Transition") {
      if (conflictTesting(point, drawnPoints) == "freeSpace") {
        drawnPoints = List.from(drawnPoints)
          ..add(DrawnPoint(point, selectedShape, selectedColor));
        drawnPointsStreamController.add(drawnPoints);
        setState(() {
          matrices[selectedShape.toString()] =
              matrices[selectedShape.toString()] + 1;
          currentMarking = m2d.zeros(1, matrices["Place"]);
        });
      }
    }
  }

  void onPanUpdate(details) {
    if (selectedShape == "Arc") {
      if (currentArc.point1 != null) {
        RenderBox box = context.findRenderObject();
        Offset point = box.globalToLocal(details.globalPosition);
        point = (point ~/ 25) * 25;
        currentArc = DrawnArc(currentArc.point1, point, selectedColor);
        currentArcStreamController.add(currentArc);
      }
    }
  }

  void onPanEnd(details) {
    if (selectedShape == "Arc") {
      try {
        final conflictTest = conflictTesting(currentArc.point2, drawnPoints);
        if (conflictTest != "freeSpace") {
          currentArc =
              DrawnArc(currentArc.point1, currentArc.point2, selectedColor);
          drawnArcs = List.from(drawnArcs)..add(currentArc);
          drawnArcsStreamController.add(drawnArcs);
          currentDiffMatrix = differenceMatrixBuilder(
              matrices, selectedShape, drawnArcs, drawnPoints);
          print(currentDiffMatrix);
        } else {
          currentArc = DrawnArc(Offset(0, 0), Offset(0, 0), selectedColor);
          currentArcStreamController.add(currentArc);
        }
      } on Error {}
    }
  }

  void onTap(details) {
    RenderBox box = context.findRenderObject();
    Offset point = box.globalToLocal(details.globalPosition);
    point = (point ~/ 25) * 25;
    onPanStart(details);
    if (selectedShape == "Token") {
      if (conflictTesting(point, drawnPoints) == "placeTap") {
        //update place matrix with recieved token. (set the state)
        int placeDetails = placeFinder(drawnPoints, point);
        // add function which finds all token and place overlaps and then created the currentMarking.
        drawnPoints = List.from(drawnPoints)
          ..add(DrawnPoint(point, "Token", selectedColor));
        drawnPointsStreamController.add(drawnPoints);
        currentMarking = currentMarkingBuilder(drawnPoints, matrices);
        print(currentMarking);
      }
    }
  }

  String conflictTesting(point, drawnPoints) {
    for (int i = 0; i < drawnPoints.length; ++i) {
      if (point == drawnPoints[i].point) {
        if (drawnPoints[i].shape == "Place") {
          return "placeTap";
        }
        return "transTap";
      }
    }
    return "freeSpace";
  }
}
