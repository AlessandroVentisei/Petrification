import 'dart:convert';
import 'dart:html' as html;

import 'package:drawing_app/currentMarking.dart';
import 'package:drawing_app/simulate_net.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './sketcher.dart';
import './drawn_line.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:matrix2d/matrix2d.dart';
import './difference_matrix_builder.dart';
import 'package:file_picker_web/file_picker_web.dart' as webPicker;

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
  DrawnArc currentArc;
  Color selectedColor = Colors.black;
  String selectedShape;
  String selectedPhotonicShape;
  double x = 0.0;
  double y = 0.0;
  List<dynamic> currentMarking;
  List<dynamic> currentDiffMatrix;
  Matrix2d m2d = Matrix2d();
  List<DrawnJunction> drawnJunctions = <DrawnJunction>[];
  DrawnJunction hoverJunction;
  bool circuitPage;

  @override
  initState() {
    super.initState();
    circuitPage = false;
    selectedPhotonicShape = "4-Port";
  }

  @override
  Widget build(BuildContext context) {
    return (circuitPage == true)
        ?
        // high level photonic circuit building branch.
        Scaffold(
            backgroundColor: Colors.white,
            body: Stack(children: [
              buildHoverJunction(context, x, y),
              buildPhotonicShapeToolbar()
            ]),
          )
        :
        // pn building page lives here.
        Scaffold(
            backgroundColor: Colors.white,
            body: Stack(children: [
              buildAllPoints(context),
              buildAllArcs(context),
              buildCurrentArc(context),
              buildPNShapeToolbar(),
            ]),
          );
  }

  Widget buildHoverJunction(BuildContext context, x, y) {
    return MouseRegion(
        onHover: _updateLocation,
        child: GestureDetector(
          onTapDown: onTapPhotonic,
          child: RepaintBoundary(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.fromLTRB(100, 0, 0, 0),
                color: Colors.transparent,
                alignment: Alignment.topLeft,
                child: CustomPaint(
                    painter: DrawAllJunctions(
                        junctions: drawnJunctions,
                        hoverJunction: DrawnJunction(
                            Offset(x, y), selectedPhotonicShape)))),
          ),
        ));
  }

  void _updateLocation(PointerEvent details) {
    // TODO validate the placement of junctions here
    // 1) no 4-port placed within 100 px of eachother.
    // 2) no standalong junctions if the drawnJunctions array is non-empty.
    // 3) junctions must align either in dx or dy so the ports match up
    setState(() {
      this.x = ((details.localPosition.dx - 100) ~/ 25.0) * 25.0;
      this.y = ((details.localPosition.dy) ~/ 25.0) * 25.0;
    });
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

  void onTapPhotonic(details) {
    RenderBox box = context.findRenderObject();
    Offset point = box.globalToLocal(details.globalPosition);
    point = (point ~/ 25) * 25;
    print(drawnJunctions);
    setState(() {
      this.drawnJunctions.add(DrawnJunction(
          Offset(point.dx - 100, point.dy), selectedPhotonicShape));
    });
    // add a junction of the type selectedPhotonicShape with position of point
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

  Widget buildPNShapeToolbar() {
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
          buildStateButton(circuitPage),
          buildShapeButton("Place"),
          buildShapeButton("Transition"),
          buildShapeButton("Arc"),
          buildShapeButton("Token"),
          buildShapeButton("Delete"),
          buildSimulateButton("Simulate"),
          buildSaveButton("Save"),
          buildUploadButton("Upload")
        ],
      ),
    );
  }

  Widget buildPhotonicShapeToolbar() {
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
          buildStateButton(circuitPage),
          buildPhotonicShapeButton("4-Port"),
          buildPhotonicShapeButton("3-Port"),
          buildPhotonicShapeButton("2-Port")
        ],
      ),
    );
  }

  Widget buildStateButton(bool circuitPage) {
    // the button for switching between PN and photonics pages.
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: false,
        backgroundColor: Colors.yellow,
        child: Container(
          child: Text(
              (circuitPage == false) ? "Photoic-Circuit" : "Petri-Net Rep",
              style: TextStyle(fontSize: 8, color: Colors.black)),
        ),
        onPressed: () {
          if (circuitPage == false) {
            setState(() {
              this.circuitPage = true;
            });
          } else {
            setState(() {
              this.circuitPage = false;
            });
          }
        },
      ),
    );
  }

  Widget buildPhotonicShapeButton(String string) {
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
            selectedPhotonicShape = string;
          });
        },
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
        onPressed: () async {
          // save the PN to a file.
          Map<String, dynamic> stringDrawnPoints = {
            "transitions": json.encode(drawnPoints),
            "places": json.encode(drawnPlaces),
            "arcs": json.encode(drawnArcs)
          };
          // prepare
          await saveDialog(context);
          final bytes = utf8.encode(jsonEncode(stringDrawnPoints));
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = fileName + ".txt";
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

  Widget buildUploadButton(String string) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: false,
        backgroundColor: Colors.green,
        child: Container(
          child: Text(string, style: TextStyle(fontSize: 8)),
        ),
        onPressed: () async {
          if (kIsWeb) {
            final html.File file = await webPicker.FilePicker.getFile(
              allowedExtensions: ['txt'],
            );

            final reader = html.FileReader();
            reader.readAsText(file);
            await reader.onLoad.first;
            Map<String, dynamic> data = jsonDecode(reader.result);
            var transitions = jsonDecode(data["transitions"]);
            var places = jsonDecode(data["places"]);
            var arcs = jsonDecode(data["arcs"]);
            List<DrawnPoint> fileDrawnPoints = List.generate(transitions.length,
                (index) => DrawnPoint.fromJson(transitions[index]));
            List<Place> fileDrawnPlace = List.generate(
                places.length, (index) => Place.fromJson(places[index]));
            List<DrawnArc> fileDrawnArc = List.generate(
                arcs.length, (index) => DrawnArc.fromJson(arcs[index]));
            setState(() {
              drawnPoints = fileDrawnPoints;
              drawnPlaces = fileDrawnPlace;
              drawnArcs = fileDrawnArc;
              currentDiffMatrix = differenceMatrixBuilder(
                  selectedShape, drawnArcs, drawnPoints, drawnPlaces);
            });
          }
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
    }
    if (selectedShape == "Transition") {
      if (conflictTesting(point, drawnPoints, drawnPlaces) == "freeSpace") {
        setState(() {
          drawnPoints = List.from(drawnPoints)
            ..add(DrawnPoint(point, selectedShape, selectedColor));
        });
      }
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
          // await displayArcDialog(context);
          codeDialog = 1;
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

  TextEditingController _saveFileController = TextEditingController();
  String fileName;
  saveDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('FileName'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  fileName = value;
                });
              },
              controller: _saveFileController,
              decoration: InputDecoration(hintText: "Input file name"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('SAVE'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
