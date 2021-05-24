import 'package:flutter/material.dart';

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
  List<Offset> points = <Offset>[];
  List<Color> colors = <Color>[];
  Color color;
  double strokeWidth = 5.0;

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
      // appBar: AppBar(
      //   title: Text("Drawing App"),
      // ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: _transformationController,
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  RenderBox box = context.findRenderObject();
                  Offset point;
                  if (_transformationController.value != Matrix4.identity()) {
                    final position = _doubleTapDetails.localPosition;
                    point = box.globalToLocal(details.globalPosition).translate(0, 0);
                    double distance = (position - point).distance;
                    double direction = (position - point).direction;
                    point = point.translate(distance / direction, distance / direction);
                  } else {
                    point = box.globalToLocal(details.globalPosition);
                  }
                  points = List.from(points)..add(point);
                  colors = List.from(colors)..add(color ?? Colors.redAccent);
                  print(point.toString());
                });
              },
              onPanEnd: (DragEndDetails details) {
                points.add(null);
                colors.add(null);
              },
              onDoubleTapDown: _handleDoubleTapDown,
              onDoubleTap: _handleDoubleTap,
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
                    strokeWidth: strokeWidth,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 100.0,
            bottom: 0.0,
            right: 10.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.redAccent,
                    child: Container(),
                    onPressed: () {
                      color = Colors.redAccent;
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
                      color = Colors.blueAccent;
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
                      color = Colors.deepOrange;
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
                      color = Colors.green;
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
                      color = Colors.lightBlue;
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
                      color = Colors.black;
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
                      color = Colors.white;
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 100.0,
            left: 10.0,
            child: Column(
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
        ],
      ),
    );
  }
}

class Sketcher extends CustomPainter {
  final List<Offset> points;
  final List<Color> colors;
  final double strokeWidth;

  Sketcher({this.strokeWidth, this.points, this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; ++i) {
      if (points[i] != null && points[i + 1] != null && colors[i] != null) {
        paint.color = colors[i];
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return oldDelegate.points != points;
  }
}
