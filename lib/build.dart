import 'package:drawing_app/currentMarking.dart';
import 'package:drawing_app/simulate_net.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        buildAllPoints(context),
        buildAllArcs(context),
        buildCurrentArc(context),
        buildShapeToolbar(),
      ]),
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
            child: CustomPaint(
              painter: ArcSketcher(
                arcs: [currentArc],
              ),
            )),
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
          child: CustomPaint(
            painter: ArcSketcher(
              arcs: drawnArcs,
            ),
          )),
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
        child: CustomPaint(
          painter: Sketcher(
            points: drawnPoints,
          ),
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
          buildSimulateButton("Simulate"),
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

  Widget buildSimulateButton(String string) {
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
            currentMarking =
                simulateNet(currentMarking, currentDiffMatrix, matrices);
            drawnPoints = onChangeMarking(drawnPoints, currentMarking);
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
        setState(() {
          currentArc = DrawnArc(point, point + Offset(5, 5), selectedColor);
        });
      } else {
        currentArc = DrawnArc(Offset(0, 0), Offset(0, 0), selectedColor);
        return;
      }
    }
    if (selectedShape == "Place" || selectedShape == "Transition") {
      if (conflictTesting(point, drawnPoints) == "freeSpace") {
        setState(() {
          drawnPoints = List.from(drawnPoints)
            ..add(DrawnPoint(point, selectedShape, selectedColor));
        });
        setState(() {
          matrices[selectedShape.toString()] =
              matrices[selectedShape.toString()] + 1;
          currentMarking = List.filled(matrices["Place"], 0);
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
        setState(() {
          currentArc = DrawnArc(currentArc.point1, point, selectedColor);
        });
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
          setState(() {
            drawnArcs = List.from(drawnArcs)..add(currentArc);
          });
          currentDiffMatrix = differenceMatrixBuilder(
              matrices, selectedShape, drawnArcs, drawnPoints);
          print(currentDiffMatrix);
        } else {
          setState(() {
            currentArc = DrawnArc(Offset(0, 0), Offset(0, 0), selectedColor);
          });
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
        setState(() {
          drawnPoints = List.from(drawnPoints)
            ..add(DrawnPoint(point, "Token", selectedColor));
        });
        currentMarking = currentMarkingBuilder(drawnPoints, matrices);
        print(currentMarking);
      }
    }
  }

  List<DrawnPoint> onChangeMarking(
      List<DrawnPoint> drawnPoints, currentMarking) {
    List<DrawnPoint> drawingPointer = drawnPoints;
    int placeNum = 0;
    for (int i = 0; i < currentMarking.length; i++) {
      if (currentMarking[i] == 1) {
        for (int j = 0; j < drawingPointer.length; j++) {
          if (drawingPointer[j].shape == "Place") {
            if (placeNum == i) {
              drawingPointer = List.from(drawingPointer)
                ..add(DrawnPoint(
                    drawingPointer[j].point, "Token", selectedColor));
            }
            placeNum++;
          }
        }
      } else {
        int pointer = tokenRemover(i, drawingPointer);
        if (pointer != null) {
          drawingPointer = List.from(drawingPointer)..removeAt(pointer);
        } else {
          drawingPointer = List.from(drawingPointer);
        }
      }
    }
    return drawingPointer;
  }

  int tokenRemover(placeNum, List<DrawnPoint> drawnPoints) {
    //token is being removed from place 1, but is actually recorded in the list as token 0...
    //the tokens aren't stored sequentially all the time, so we need to correlate the place and token
    int tokenPointer = 0;
    // find place 1 -> find token from coords of place -> remove that element from the drawingPointer list.
    int placePointer = placeFinderBySequence(drawnPoints, placeNum);
    for (int i = 0; i < drawnPoints.length; i++) {
      if (drawnPoints[i].shape == "Token") {
        if (drawnPoints[placePointer].point == drawnPoints[i].point) {
          tokenPointer = i;
          return tokenPointer;
        }
      }
    }
    return null;
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
