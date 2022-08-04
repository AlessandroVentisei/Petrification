import 'dart:convert';
import 'dart:html' as html;

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
  List<Place> drawnPlaces = <Place>[];
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
            places: drawnPlaces,
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
          buildSaveButton("Save")
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
            drawnPlaces =
                simulateNet(drawnPlaces, drawnPoints, currentDiffMatrix);
            drawnPoints = drawnPoints;
          });
        },
      ),
    );
  }

  Widget buildSaveButton(String string) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: false,
        backgroundColor: Colors.green,
        child: Container(
          child: Text(string, style: TextStyle(fontSize: 8)),
        ),
        onPressed: () {
          // save the PN to a file.
          String stringDrawnPoints = jsonEncode(drawnPoints[0]);
          final text = stringDrawnPoints;
          // prepare
          final bytes = utf8.encode(text);
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = 'some_name.txt';
          html.document.body.children.add(anchor);
          // download
          anchor.click();
          // cleanup
          html.document.body.children.remove(anchor);
          html.Url.revokeObjectUrl(url);
        },
      ),
    );
  }

  void onPanStart(details) {
    RenderBox box = context.findRenderObject();
    Offset point = box.globalToLocal(details.globalPosition);
    point = (point ~/ 25) * 25;
    if (selectedShape == "Arc") {
      if (conflictTesting(point, drawnPoints, drawnPlaces) != "freeSpace") {
        setState(() {
          currentArc = DrawnArc(point, point + Offset(5, 5), selectedColor, 1);
        });
      } else {
        currentArc = DrawnArc(Offset(0, 0), Offset(0, 0), selectedColor, 1);
        return;
      }
    }
    if (selectedShape == "Place") {
      if (conflictTesting(point, drawnPoints, drawnPlaces) == "freeSpace") {
        setState(() {
          drawnPlaces = List.from(drawnPlaces)
            ..add(Place(point, 0, selectedColor));
        });
      }
      setState(() {
        matrices[selectedShape.toString()] =
            matrices[selectedShape.toString()] + 1;
        currentMarking = List.filled(matrices["Place"], 0);
      });
    }
    if (selectedShape == "Transition") {
      if (conflictTesting(point, drawnPoints, drawnPlaces) == "freeSpace") {
        setState(() {
          drawnPoints = List.from(drawnPoints)
            ..add(DrawnPoint(point, selectedShape, selectedColor));
        });
      }
      setState(() {
        matrices[selectedShape.toString()] =
            matrices[selectedShape.toString()] + 1;
        currentMarking = List.filled(matrices["Place"], 0);
      });
    }
    if (selectedShape == "Delete") {
      setState(() {
        drawnPlaces.removeWhere((element) => element.point == point);
        drawnPoints.removeWhere((element) => element.point == point);
        drawnArcs.removeWhere(
            (element) => (element.point1 == point || element.point2 == point));
        currentArc = DrawnArc(Offset(0, 0), Offset(0, 0), Colors.white, 0);
      });
    }
  }

  void onPanUpdate(details) {
    if (selectedShape == "Arc") {
      if (currentArc.point1 != null) {
        RenderBox box = context.findRenderObject();
        Offset point = box.globalToLocal(details.globalPosition);
        point = (point ~/ 25) * 25;
        setState(() {
          currentArc = DrawnArc(currentArc.point1, point, selectedColor, 1);
        });
      }
    }
  }

  TextEditingController _textFieldController = TextEditingController();
  String valueText;
  num codeDialog;
  displayArcDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Arc Weight'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Input arc weight"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    valueText = "0";
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    codeDialog = num.parse(valueText);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  void onPanEnd(details) async {
    if (selectedShape == "Arc") {
      try {
        final conflictTest =
            conflictTesting(currentArc.point2, drawnPoints, drawnPlaces);
        if (conflictTest != "freeSpace") {
          await displayArcDialog(context);
          if (codeDialog == 0) {
            return;
          } else {
            currentArc = DrawnArc(currentArc.point1, currentArc.point2,
                selectedColor, codeDialog);
            setState(() {
              drawnArcs = List.from(drawnArcs)..add(currentArc);
            });
            currentDiffMatrix = differenceMatrixBuilder(
                selectedShape, drawnArcs, drawnPoints, drawnPlaces);
            print(currentDiffMatrix);
          }
        } else {
          setState(() {
            currentArc = DrawnArc(Offset(0, 0), Offset(0, 0), selectedColor, 1);
          });
        }
      } on Error {}
    }
  }

  TextEditingController _tokenFieldController = TextEditingController();
  String tokenText;
  num tokenDialog;
  displayTokenDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Number of tokens'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  tokenText = value;
                });
              },
              controller: _tokenFieldController,
              decoration: InputDecoration(hintText: "Input number of tokens"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    tokenText = "0";
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    tokenDialog = num.parse(tokenText);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  void onTap(details) async {
    RenderBox box = context.findRenderObject();
    Offset point = box.globalToLocal(details.globalPosition);
    point = (point ~/ 25) * 25;
    onPanStart(details);
    if (selectedShape == "Token") {
      if (conflictTesting(point, drawnPoints, drawnPlaces) == "placeTap") {
        await displayTokenDialog(context);
        var selectedPlace =
            drawnPlaces.where((element) => element.point == point);
        setState(() {
          selectedPlace.first.tokens += tokenDialog;
        });
        // currentMarking =
        //     currentMarkingBuilder(drawnPoints, drawnPlaces, matrices);
        print(drawnPlaces);
      }
    }
  }

  List<DrawnPoint> onChangeMarking(
      List<DrawnPoint> drawnPoints, List<Place> drawnPlaces, currentMarking) {
    // this function is to re-draw points based on marking and drawn points.
    // current marking [0,1,0]
    // drawn points: place, transition, things
    /*
    List<DrawnPoint> drawingPointer = drawnPoints;
    for (int i = 0; i < currentMarking.length; i++) {
      int placeNum = 0;
      if (currentMarking[i] >= 1) {
        for (int j = 0; j < drawingPointer.length; j++) {
          // the issue is here, the placeNum counter counts beyond the number of places?
          if (drawingPointer[j].shape == "Place") {
            if (placeNum == i) {
              for (int l = 0; l < currentMarking[i]; l++) {
                drawingPointer = List.from(drawingPointer)
                  ..add(DrawnPoint(
                      drawingPointer[j].point, "Token", selectedColor));
              }
            }
            placeNum++;
          }
        }
      } else {
        var place = drawingPointer
            .where((element) => element.shape == "Place")
            .toList();
        for (int l = 0; l < places.length; l++) {
          // place num and drawn Points token remover here
          drawingPointer.removeWhere((element) =>
              (element.shape == "Token" && element.point == places[l].point));
        }
      }*/
    // }

    // return drawingPointer;
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

  String conflictTesting(
      point, List<DrawnPoint> drawnPoints, List<Place> drawnPlaces) {
    final transitionTap =
        drawnPoints.where((element) => point == element.point);
    final placeTap = drawnPlaces.where((element) => point == element.point);
    if (placeTap.length != 0) {
      return "placeTap";
    }
    if (transitionTap.length != 0) {
      return "transTap";
    }
    return "freeSpace";
  }
}
