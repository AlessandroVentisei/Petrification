import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _globalKey = new GlobalKey();
  List<DrawnLine> lines = <DrawnLine>[];
  DrawnLine line;
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;

  StreamController<List<DrawnLine>> linesStreamController = StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController = StreamController<DrawnLine>.broadcast();

  Future<void> _save() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
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

  Future<void> _clear() async {
    setState(() {
      lines = [];
      line = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(4.0),
              alignment: Alignment.topLeft,
              color: Colors.yellow[50],
              child: StreamBuilder<List<DrawnLine>>(
                stream: linesStreamController.stream,
                builder: (context, snapshot) {
                  return CustomPaint(
                    painter: Sketcher(
                      lines: lines,
                    ),
                  );
                },
              ),
            ),
          ),
          GestureDetector(
            onPanStart: (DragStartDetails details) {
              RenderBox box = context.findRenderObject();
              Offset point;

              point = box.globalToLocal(details.globalPosition);
              line = DrawnLine([point], selectedColor, selectedWidth);
            },
            onPanUpdate: (DragUpdateDetails details) {
              RenderBox box = context.findRenderObject();
              Offset point;

              point = box.globalToLocal(details.globalPosition);

              List<Offset> path = List.from(line.path)..add(point);
              line = DrawnLine(path, selectedColor, selectedWidth);
              currentLineStreamController.add(line);
            },
            onPanEnd: (DragEndDetails details) {
              lines = List.from(lines)..add(line);

              linesStreamController.add(lines);
            },
            child: RepaintBoundary(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.all(4.0),
                alignment: Alignment.topLeft,
                color: Colors.transparent,
                child: StreamBuilder<DrawnLine>(
                    stream: currentLineStreamController.stream,
                    builder: (context, snapshot) {
                      return CustomPaint(
                        painter: Sketcher(
                          lines: [line],
                        ),
                      );
                    }),
              ),
            ),
          ),
          Positioned(
            bottom: 100.0,
            right: 10.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    selectedWidth = 5.0;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    selectedWidth = 10.0;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: 16.0,
                      height: 16.0,
                      decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(16.0)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    selectedWidth = 15.0;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(20.0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 40.0,
            right: 10.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _clear,
                  child: CircleAvatar(
                    child: Icon(
                      Icons.create,
                      size: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Divider(
                  height: 10.0,
                ),
                GestureDetector(
                  onTap: _save,
                  child: CircleAvatar(
                    child: Icon(
                      Icons.save,
                      size: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                Divider(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.redAccent,
                    child: Container(),
                    onPressed: () {
                      setState(() {
                        selectedColor = Colors.redAccent;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.blueAccent,
                    child: Container(),
                    onPressed: () {
                      setState(() {
                        selectedColor = Colors.blueAccent;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.deepOrange,
                    child: Container(),
                    onPressed: () {
                      setState(() {
                        selectedColor = Colors.deepOrange;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.green,
                    child: Container(),
                    onPressed: () {
                      setState(() {
                        selectedColor = Colors.green;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.lightBlue,
                    child: Container(),
                    onPressed: () {
                      setState(() {
                        selectedColor = Colors.lightBlue;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.black,
                    child: Container(),
                    onPressed: () {
                      setState(() {
                        selectedColor = Colors.black;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    child: Container(),
                    onPressed: () {
                      setState(() {
                        selectedColor = Colors.white;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;

  Sketcher({this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      if (lines[i] == null) continue;
      for (int j = 0; j < lines[i].path.length - 1; ++j) {
        if (lines[i].path[j] != null && lines[i].path[j + 1] != null) {
          paint.color = lines[i].color;
          paint.strokeWidth = lines[i].width;
          canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;

  DrawnLine(this.path, this.color, this.width);
}
