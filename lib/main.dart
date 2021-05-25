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
  List<Offset> points = <Offset>[];
  List<Color> colors = <Color>[];
  List<double> strokes = [];
  Color color = Colors.black;
  double strokeWidth = 5.0;

  Future<void> _save() async {
    // try {
    RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    var something = await ImageGallerySaver.saveImage(
      pngBytes,
      quality: 100,
      name: DateTime.now().toIso8601String() + ".png",
      isReturnImagePathOfIOS: true,
    );

    // } catch (e) {
    //   print(e);
    // }
  }

  Future<void> _clear() async {
    points = [];
    colors = [];
    strokes = [];

    setState(() {});
  }

  final _transformationController = TransformationController();
  TapDownDetails _doubleTapDetails;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails.localPosition;
      // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (DragUpdateDetails details) {
              setState(() {
                RenderBox box = context.findRenderObject();
                Offset point;
                if (_transformationController.value == Matrix4.identity()) {
                  point = box.globalToLocal(details.globalPosition);
                } else {
                  point = _transformationController.toScene(details.globalPosition);
                }
                points = List.from(points)..add(point);
                colors = List.from(colors)..add(color ?? Colors.redAccent);
                strokes = List.from(strokes)..add(strokeWidth ?? 5.0);
              });
            },
            onPanEnd: (DragEndDetails details) {
              points.add(null);
              colors.add(null);
              strokes.add(null);
            },
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.all(4.0),
                alignment: Alignment.topLeft,
                color: Colors.yellow[50],
                child: CustomPaint(
                  painter: Sketcher(
                    points: points,
                    colors: colors,
                    strokes: strokes,
                  ),
                ),
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
                    strokeWidth = 5.0;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    strokeWidth = 10.0;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: 16.0,
                      height: 16.0,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16.0)),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    strokeWidth = 15.0;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20.0)),
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
                        color = Colors.redAccent;
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
                        color = Colors.blueAccent;
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
                        color = Colors.deepOrange;
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
                        color = Colors.green;
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
                        color = Colors.lightBlue;
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
                        color = Colors.black;
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
                        color = Colors.white;
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
  final List<Offset> points;
  final List<Color> colors;
  final List<double> strokes;

  Sketcher({this.strokes, this.points, this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; ++i) {
      if (points[i] != null && points[i + 1] != null && colors[i] != null) {
        paint.color = colors[i];
        paint.strokeWidth = strokes[i];
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return oldDelegate.points != points;
  }
}
