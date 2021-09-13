import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drawing_app/drawn_line.dart';
import 'package:drawing_app/sketcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  GlobalKey _globalKey = new GlobalKey();
  List<DrawnLine> lines = <DrawnLine>[];
  List<DrawnLine> arcs = <DrawnLine>[];
  DrawnLine line;
  DrawnLine arc;
  Color selectedColor = Colors.black;
  String selectedShape;
  double selectedWidth = 10.0;

  StreamController<List<DrawnLine>> linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController =
      StreamController<DrawnLine>.broadcast();

  Future<void> save() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      var saved = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: DateTime.now().toIso8601String() + ".png",
        isReturnImagePathOfIOS: true,
      );
      print(saved);
    } catch (e) {
      print(e);
    }
  }

  Future<void> clear() async {
    setState(() {
      lines.removeLast();
      line = null;
    });
  }

  bool conflictTest(lines) {
    //implement a test for conflicting elements at a coordinate set before painting is allowed.
    List<Offset> paths = [];
    for (int i = 0; i < lines.length; ++i) {
      for (int j = 0; j < lines[i].path.length; ++j) {
        if (paths.any((element) => lines[i].path.contains(element))) {
          paths.remove(lines[i].path[j]);
          return false;
        } else {
          paths.add(lines[i].path[j]);
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          buildAllPaths(context),
          buildCurrentPath(context),
          buildShapeToolbar(),
          buildClearButton(),
        ],
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return GestureDetector(
      //onTapDown: onTapDown,
      //onTapUp: onTapUp,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(4.0),
          color: Colors.transparent,
          alignment: Alignment.topLeft,
          child: StreamBuilder<DrawnLine>(
            stream: currentLineStreamController.stream,
            builder: (context, snapshot) {
              return CustomPaint(
                painter: Sketcher(
                  lines: [arc, line],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.transparent,
        padding: EdgeInsets.all(4.0),
        alignment: Alignment.topLeft,
        child: StreamBuilder<List<DrawnLine>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: lines + arcs,
              ),
            );
          },
        ),
      ),
    );
  }

  void onPanStart(details) {
    RenderBox box = context.findRenderObject();
    Offset point = box.globalToLocal(details.globalPosition);
    point = (point ~/ 25) * 25;
    if (selectedShape == "Arc") {
      arc = DrawnLine([point], selectedColor, selectedShape, 2);
      currentLineStreamController.add(arc);
    }
    if (selectedShape == "Place" || selectedShape == "Transition") {
      line = DrawnLine([point], selectedColor, selectedShape, selectedWidth);
      //currentLineStreamController.add(line);
    }
    if (selectedShape == "Delete") {
      line = DrawnLine([point], selectedColor, selectedShape, selectedWidth);
      if (conflictTest(lines + arcs + [line]) == false) {
        clear();
      }
    }
  }

  void onPanUpdate(details) {
    if (selectedShape == "Arc") {
      RenderBox box = context.findRenderObject();
      Offset point = box.globalToLocal(details.globalPosition);
      point = (point ~/ 25) * 25;
      List<Offset> path = List.from(arc.path)..add(point);
      arc = DrawnLine([path[0], path.last], selectedColor, selectedShape, 2);
      currentLineStreamController.add(arc);
    }
  }

  void onPanEnd(details) {
    if (selectedShape == "Arc") {
      arc = DrawnLine(
          [arc.path[0], arc.path.last], selectedColor, selectedShape, 2);
      arcs = List.from(arcs)..add(arc);
      linesStreamController.add(arcs);
    }
    if (selectedShape == "Place" || selectedShape == "Transition") {
      line = DrawnLine(line.path, selectedColor, selectedShape, selectedWidth);
      lines = List.from(lines)..add(line);
      if (conflictTest(lines) == false) {
        setState(() {
          lines.removeLast();
          line = null;
        });
      } else {
        linesStreamController.add(lines);
      }
    }
    if (selectedShape == "Delete") {
      linesStreamController.add(lines);
    }
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

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: CircleAvatar(
        child: Icon(
          Icons.create,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
