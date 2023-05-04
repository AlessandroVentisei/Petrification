import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui';
import 'package:drawing_app/photonic_mapper.dart';
import 'package:drawing_app/simulate_net.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import './sketcher.dart';
import './drawn_line.dart';
import 'package:flutter/rendering.dart';
import 'package:matrix2d/matrix2d.dart';
import './difference_matrix_builder.dart';
import 'package:file_picker/file_picker.dart';
import './histogram_plots.dart';

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
  List<DrawnLabel> drawnLabels = <DrawnLabel>[];
  List<Place> drawnOutputPlaces = [];
  DrawnArc currentArc = DrawnArc(Offset.zero, Offset.zero, Colors.black, 1);
  Color selectedColor = Colors.black;
  String selectedShape = '';
  late String selectedPhotonicShape;
  double x = 0.0;
  double y = 0.0;
  List<dynamic> currentMarking = [];
  List<List<double>> currentDiffMatrix = [];
  Matrix2d m2d = Matrix2d();
  List<DrawnJunction> drawnJunctions = <DrawnJunction>[];
  late DrawnJunction hoverJunction;
  late bool circuitPage;
  late bool showHover;

  @override
  initState() {
    super.initState();
    circuitPage = false;
    showHover = true;
    selectedPhotonicShape = "4-Port";
  }

  @override
  Widget build(BuildContext context) {
    return (circuitPage == true)
        ?
        // high level photonic circuit building branch.
        Scaffold(
            backgroundColor: Colors.white,
            body: Stack(clipBehavior: Clip.none, children: [
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
                        hoverJunction: (showHover)
                            ? DrawnJunction(
                                Offset(x, y), selectedPhotonicShape, "hover",
                                junctionConnections: [])
                            : DrawnJunction(Offset(-200, -200),
                                selectedPhotonicShape, "hover",
                                junctionConnections: [])))),
          ),
        ));
  }

  void _updateLocation(PointerEvent details) {
    var mouseDx = details.localPosition.dx - 100;
    var mouseDy = details.localPosition.dy;
    var junctionsWithin100px;
    // print(mouseDx);
    if (selectedPhotonicShape == "2-Port") {
      junctionsWithin100px = drawnJunctions.where(((element) =>
          ((element.point.dx - mouseDx).abs() < 100 &&
              (element.point.dy - mouseDy).abs() < 200)));
    } else {
      junctionsWithin100px = drawnJunctions.where(((element) =>
          ((element.point.dx - mouseDx).abs() < 200 &&
              (element.point.dy - mouseDy).abs() < 200)));
    }
    // TODO validate the placement of junctions here
    // 1) no 4-port placed within 100 px of eachother.
    if (junctionsWithin100px.length == 0) {
      setState(() {
        showHover = true;
        this.x = ((mouseDx) / 25.0).round() * 25.0;
        this.y = ((mouseDy) / 25.0).round() * 25.0;
      });
    } else {
      setState(() {
        showHover = false;
      });
    }
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
    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    double pointx = (point.dx / 25).roundToDouble() * 25.0;
    double pointy = (point.dy / 25).roundToDouble() * 25.0;

    if (showHover) {
      // showHover is also acting as a validation indicator...
      List<JunctionConnection> currentJunctionConnections = junctionConnections(
          drawnJunctions, pointx, pointy, selectedPhotonicShape);
      setState(() {
        // add the photonic Junction to a list of drawnJunctions here and setState to redraw.
        this.drawnJunctions.add(DrawnJunction(Offset(pointx - 100, pointy),
            selectedPhotonicShape, drawnJunctions.length.toString(),
            junctionConnections: currentJunctionConnections));
      });
    }
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
              labels: drawnLabels,
              arcs: []),
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
          buildUploadButton("Upload"),
          buildGraphButton("ShowGraph")
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
          buildPhotonicShapeButton("2-Port"),
          buildPhotonicShapeButton("Create PN")
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
        onPressed: () async {
          if (string != "Create PN") {
            setState(() {
              selectedPhotonicShape = string;
            });
          } else {
            // run the create Photonic Simulation Map Function
            var photonicMap = structPlotter(drawnJunctions);
            final pnLayout = pnPlotter(photonicMap);
            // Hand this off to the PN creation tool
            await saveDialog(context);
            final bytes = utf8.encode(jsonEncode(pnLayout));
            final blob = html.Blob([bytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            final anchor =
                html.document.createElement('a') as html.AnchorElement
                  ..href = url
                  ..style.display = 'none'
                  ..download = fileName + ".txt";
            html.document.body!.children.add(anchor);
            // download
            anchor.click();
            // cleanup
            html.document.body!.children.remove(anchor);
            html.Url.revokeObjectUrl(url);
          }
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

  Widget buildGraphButton(String string) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: false,
        backgroundColor: Colors.black,
        child: Container(
          child: Text(string, style: TextStyle(fontSize: 8)),
        ),
        onPressed: () {
          int maxIterations = 20;
          List<Iterable<SfCartesianChart>> histograms =
              createPlotsFromOutputPlaces(
                  context, drawnOutputPlaces, maxIterations, drawnLabels);
          displayHistograms(context, histograms);
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
          const maxIterations = 20;
          for (int i = 0; i < maxIterations; i++) {
            // add in check for dead net.
            drawnPlaces =
                simulateNet(drawnPlaces, drawnPoints, currentDiffMatrix);
          }
          // horrible bit of code to update drawnOutputPlaces with the drawnPlaces token values.
          drawnOutputPlaces = drawnPlaces
              .where((element) =>
                  drawnOutputPlaces
                      .where(
                          (outputPlace) => outputPlace.point == element.point)
                      .length ==
                  1)
              .toList();
          // now we can plot each histogram, as long as we can group the places into junctions.

          // add in a function here to count output tokens in places.
          setState(() {
            drawnPlaces = drawnPlaces;
            drawnPoints = drawnPoints;
            drawnOutputPlaces = drawnOutputPlaces;
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
          html.document.body!.children.add(anchor);
          // download
          anchor.click();
          // cleanup
          html.document.body!.children.remove(anchor);
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
            FilePickerResult? result = await FilePicker.platform.pickFiles();
            String? fileBytes =
                new String.fromCharCodes(result!.files.first.bytes!.toList());
            Map<String, dynamic> data = jsonDecode(fileBytes);
            var transitions = jsonDecode(data["transitions"] ??= "[]");
            var places = jsonDecode(data["places"] ??= "[]");
            var outputPlaces = jsonDecode(data["outputPlaces"] ??= "[]");
            var arcs = jsonDecode(data["arcs"] ??= "[]");
            var labels = jsonDecode(data["labels"] ??= "[]");
            List<DrawnPoint> fileDrawnPoints = List.generate(transitions.length,
                (index) => DrawnPoint.fromJson(transitions[index]));
            List<Place> fileOutputPlaces = List.generate(outputPlaces.length,
                (index) => Place.fromJson(outputPlaces[index]));
            List<Place> fileDrawnPlace = List.generate(
                places.length, (index) => Place.fromJson(places[index]));
            List<DrawnArc> fileDrawnArc = List.generate(
                arcs.length, (index) => DrawnArc.fromJson(arcs[index]));
            List<DrawnLabel> fileDrawnLabels = List.generate(
                labels.length, (index) => DrawnLabel.fromJson(labels[index]));
            setState(() {
              drawnPoints = fileDrawnPoints;
              drawnOutputPlaces = fileOutputPlaces;
              drawnPlaces = fileDrawnPlace;
              drawnArcs = fileDrawnArc;
              drawnLabels = fileDrawnLabels;
              currentDiffMatrix = differenceMatrixBuilder(
                  selectedShape, drawnArcs, drawnPoints, drawnPlaces);
            });
          }
        },
      ),
    );
  }

  void onPanStart(details) {
    RenderBox? box = context.findRenderObject() as RenderBox;
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
      RenderBox? box = context.findRenderObject() as RenderBox;
      Offset point = box.globalToLocal(details.globalPosition);
      point = (point ~/ 25) * 25;
      setState(() {
        currentArc = DrawnArc(currentArc.point1, point, selectedColor, 1);
      });
    }
  }

  TextEditingController _textFieldController = TextEditingController();
  late String valueText;
  late num codeDialog;
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
                    codeDialog = 0;
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
          // codeDialog = 1;
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
          }
        } else {
          setState(() {
            currentArc = DrawnArc(Offset(0, 0), Offset(0, 0), selectedColor, 1);
          });
        }
      } catch (error) {
        print(error);
      }
    }
  }

  TextEditingController _tokenFieldController = TextEditingController();
  late String tokenText;
  late num tokenDialog;
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
    RenderBox box = context.findRenderObject() as RenderBox;
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
    return -1;
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

  var scr = new GlobalKey();
  displayHistograms(
      BuildContext context, List<Iterable<SfCartesianChart>> charts) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('PN Output Port Histograms'),
            content: Container(
                height: window.physicalSize.height * 0.4,
                width: window.physicalSize.width * 0.4,
                // the List of Iterable SfCartesianCharts needs to be mapped twice
                // one mapping into a column for each itteration of scattering, and another to create a gridview box for each graph.
                child: SingleChildScrollView(
                    child: RepaintBoundary(
                        key: scr,
                        child: Column(
                            children: charts
                                .map((e) => Column(children: [
                                      Text("Scattering Iteration: " +
                                          (charts.indexOf(e) + 1).toString()),
                                      GridView.count(
                                          shrinkWrap: true,
                                          primary: false,
                                          padding: const EdgeInsets.all(20),
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          crossAxisCount: 3,
                                          children: e
                                              .map((e) => Container(child: e))
                                              .toList())
                                    ]))
                                .toList())))),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(
                  onPressed: () async {
                    RenderRepaintBoundary boundary = scr.currentContext!
                        .findRenderObject() as RenderRepaintBoundary;
                    var image = await boundary.toImage();
                    var byteData =
                        await image.toByteData(format: ImageByteFormat.png);
                    var pngBytes = byteData!.buffer.asUint8List();
                    final blob = html.Blob([pngBytes]);
                    final url = html.Url.createObjectUrlFromBlob(blob);
                    final anchor =
                        html.document.createElement('a') as html.AnchorElement
                          ..href = url
                          ..style.display = 'none'
                          ..download = "fileName" + ".png";
                    html.document.body!.children.add(anchor);
                    // download
                    anchor.click();
                    // cleanup
                    html.document.body!.children.remove(anchor);
                    html.Url.revokeObjectUrl(url);
                  },
                  child: Text('Export Screenshot'))
            ],
          );
        });
  }

  TextEditingController _saveFileController = TextEditingController();
  late String fileName;
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
