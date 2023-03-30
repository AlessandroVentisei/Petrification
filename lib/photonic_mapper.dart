import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:html' as html;
import 'package:drawing_app/drawn_line.dart';
import 'package:flutter/material.dart';

final fourPortTxt = {
  "transitions":
      "[{\"point\":\"300,200\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"300,225\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"300,275\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"300,300\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"300,350\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"300,375\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"300,425\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"300,450\",\"shape\":\"Transition\",\"color\":\"4278190080\"}]",
  "places":
      "[{\"point\":\"250,200\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"250,225\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"250,275\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"250,300\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"250,350\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"250,375\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"250,425\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"250,450\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"475,200\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"475,225\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"475,275\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"475,300\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"475,350\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"475,375\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"475,425\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"475,450\",\"tokens\":\"0\",\"color\":\"4278190080\"}]",
  "arcs":
      "[{\"point1\":\"250,200\",\"point2\":\"300,200\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"250,225\",\"point2\":\"300,225\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"250,275\",\"point2\":\"300,275\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"250,300\",\"point2\":\"300,300\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"250,350\",\"point2\":\"300,350\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"250,375\",\"point2\":\"300,375\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"250,425\",\"point2\":\"300,425\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"250,450\",\"point2\":\"300,450\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,200\",\"point2\":\"475,200\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,225\",\"point2\":\"475,225\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,200\",\"point2\":\"475,300\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,200\",\"point2\":\"475,375\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,225\",\"point2\":\"475,275\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,225\",\"point2\":\"475,350\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,225\",\"point2\":\"475,425\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,275\",\"point2\":\"475,275\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,300\",\"point2\":\"475,300\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,275\",\"point2\":\"475,225\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,275\",\"point2\":\"475,375\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,300\",\"point2\":\"475,200\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,300\",\"point2\":\"475,350\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,300\",\"point2\":\"475,425\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,350\",\"point2\":\"475,350\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,375\",\"point2\":\"475,375\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,350\",\"point2\":\"475,300\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,350\",\"point2\":\"475,225\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,375\",\"point2\":\"475,425\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,375\",\"point2\":\"475,275\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,375\",\"point2\":\"475,200\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,425\",\"point2\":\"475,425\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,425\",\"point2\":\"475,375\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,425\",\"point2\":\"475,300\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,425\",\"point2\":\"475,225\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,450\",\"point2\":\"475,350\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,450\",\"point2\":\"475,275\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,450\",\"point2\":\"475,200\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,450\",\"point2\":\"475,450\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,350\",\"point2\":\"475,450\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,275\",\"point2\":\"475,450\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"300,200\",\"point2\":\"475,450\",\"weight\":\"1\",\"color\":\"4278190080\"}]"
};

var threePortTxt = {
  "transitions":
      "[{\"point\":\"225,225\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"225,250\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"225,300\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"225,325\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"225,400\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"225,375\",\"shape\":\"Transition\",\"color\":\"4278190080\"}]",
  "places":
      "[{\"point\":\"200,225\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"200,250\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"200,300\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"200,325\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"200,375\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"200,400\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"425,225\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"425,250\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"425,300\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"425,325\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"425,375\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"425,400\",\"tokens\":\"0\",\"color\":\"4278190080\"}]",
  "arcs":
      "[{\"point1\":\"200,225\",\"point2\":\"225,225\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"200,250\",\"point2\":\"225,250\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"200,300\",\"point2\":\"225,300\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"200,325\",\"point2\":\"225,325\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"200,400\",\"point2\":\"225,400\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"225,225\",\"point2\":\"425,225\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"225,250\",\"point2\":\"425,250\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"225,300\",\"point2\":\"425,300\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"225,325\",\"point2\":\"425,325\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"225,400\",\"point2\":\"425,400\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"225,225\",\"point2\":\"425,325\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"225,250\",\"point2\":\"425,300\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"225,300\",\"point2\":\"425,250\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"225,325\",\"point2\":\"425,225\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"225,300\",\"point2\":\"425,400\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"225,325\",\"point2\":\"425,375\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"225,225\",\"point2\":\"425,400\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"225,250\",\"point2\":\"425,375\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"225,400\",\"point2\":\"425,300\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"200,375\",\"point2\":\"225,375\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"225,375\",\"point2\":\"425,375\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"225,375\",\"point2\":\"425,325\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"225,375\",\"point2\":\"425,250\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"225,400\",\"point2\":\"425,225\",\"weight\":\"2\",\"color\":\"4278190080\"}]"
};

final twoPortTxt = {
  "transitions":
      "[{\"point\":\"250,250\",\"shape\":\"Transition\",\"color\":\"4278190080\"},{\"point\":\"250,275\",\"shape\":\"Transition\",\"color\":\"4278190080\"}]",
  "places":
      "[{\"point\":\"225,250\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"225,275\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"350,250\",\"tokens\":\"0\",\"color\":\"4278190080\"},{\"point\":\"350,275\",\"tokens\":\"0\",\"color\":\"4278190080\"}]",
  "arcs":
      "[{\"point1\":\"225,250\",\"point2\":\"250,250\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"225,275\",\"point2\":\"250,275\",\"weight\":\"1\",\"color\":\"4278190080\"},{\"point1\":\"250,250\",\"point2\":\"350,250\",\"weight\":\"2\",\"color\":\"4278190080\"},{\"point1\":\"250,275\",\"point2\":\"350,275\",\"weight\":\"2\",\"color\":\"4278190080\"}]"
};

// do this process for 4-port, 3-port, and 2-port...
junctionConnections(List<DrawnJunction> drawnJunctions, double pointx,
    double pointy, String selectedPhotonicShape) {
  // if the junction is in line with another in the list then
  // it is a connection with the closest junctions it is in line with in the +x, +y, -x, -y.
  List<List<DrawnJunction>> closestXY = [[], [], [], []]; // [+X,-X,+Y,-Y]
  List<JunctionConnection> connections = [];
  closestXY[0] = drawnJunctions
      .where((element) => ((element.point.dx - pointx) == 100 &&
          (element.point.dy - pointy == 0)))
      .toList(); // connected to port 3 =>  out: 3, in: 1,
  closestXY[1] = drawnJunctions
      .where((element) =>
          (element.point.dx - pointx) == -300 &&
          (element.point.dy - pointy == 0))
      .toList(); // connected to port 1 => out: 1, in: 3,
  closestXY[2] = drawnJunctions
      .where((element) =>
          ((element.point.dy - pointy) == -200) &&
          (element.point.dx - pointx == -100))
      .toList(); // connected to port 2 => out: 4, in: 2,
  closestXY[3] = drawnJunctions
      .where((element) =>
          ((element.point.dy - pointy) == 200) &&
          (element.point.dx - pointx == -100))
      .toList(); // connected to port 4 => out: 2, in: 4,
  var input;
  var output;
  for (int i = 0; i < 4; i++) {
    // set the output and input ports for this given X,Y case
    switch (i) {
      case (0):
        input = 1;
        output = 3;
        break;
      case (1):
        input = 3;
        output = 1;
        break;
      case (2):
        input = 2;
        output = 4;
        break;
      case (3):
        input = 4;
        output = 2;
        break;
    }
    if (closestXY[i].length != 0) {
      // grab junction being connected to.
      DrawnJunction connectedJunction = drawnJunctions
          .where((element) => element.point == closestXY[i][0].point)
          .first;
      if (selectedPhotonicShape == "3-Port") {
        output += -1;
      }
      connections
          .add(JunctionConnection(closestXY[i].first.serial, output, input));
      // reversed input/output labels
      connectedJunction.junctionConnections.add(JunctionConnection(
          (drawnJunctions.length).toString(), input, output));
    }
  }
  return connections;
}

structPlotter(List<DrawnJunction> drawnJunctions) {
  // returns the PN struct for a given set of junctions once connections have been established.
  // init the scattering map with the first junction drawn.
  final initJunction = drawnJunctions.first;
  List<List<DrawnJunction>> scatteringMap = [
    [initJunction]
  ];
  List<DrawnJunction> newArray = [];
  List<DrawnJunction> oldArray = [initJunction];
  int scatteringItterations = 15;

  // 5 steps of scattering currently
  for (int s = 1; s < scatteringItterations; s++) {
    // go through all the junctions in the previous step
    for (int k = 0; k < oldArray.length; k++) {
      List<DrawnJunction> drawnJunctionsConnected = [];
      DrawnJunction junctionObj;
      // go through each connection in the previous step and
      // find the drawn junctions for the new step.
      for (int l = 0; l < oldArray[k].junctionConnections.length; l++) {
        junctionObj = drawnJunctions[
            int.parse(oldArray[k].junctionConnections[l].junction)];
        drawnJunctionsConnected.add(junctionObj);
      }
      newArray.addAll(drawnJunctionsConnected);
    }
    scatteringMap = [...scatteringMap, newArray.toSet().toList()];
    // set the old array for the next step and clear the newArray
    oldArray = newArray;
    newArray = [];
  }
  return scatteringMap;
}

pnPlotter(List<List<DrawnJunction>> map) {
  // here we need to draw out the PN using the map we have from earlier.
  // the map is a list of lists of DrawnJunctions involved in each step.
  Map<String, List<dynamic>> pnFile = {
    "transitions": [],
    "places": [],
    "arcs": [],
    "labels": [],
    "outputPlaces": []
  };
  List<DrawnJunction> newJunctions = [];
  List<DrawnJunction> oldJunctions = [];
  var x = 0;
  var y = 0;
  List<Place> outputPlaces = [];
  Map<String, dynamic> currentJunction;
  for (int s = 0; s < map.length; s++) {
    for (int i = 0; i < map[s].length; i++) {
      // draw a 4-port shape...
      // y itterates with the number of scattering instances in a single step.
      // x itterates with the step number of the simulation.
      x = (300 * s);
      y = (300 * i);
      // set current setp's junctionConnections
      newJunctions = map[s];
      // handing in the map n-1 junctions
      currentJunction =
          getJunction(x, y, map[s][i].shape, oldJunctions, map[s][i].serial, s);
      // get just the output places in the current junction.
      outputPlaces = getOutputPlaces(currentJunction);
      pnFile["transitions"] = [
        ...pnFile["transitions"],
        ...currentJunction["transitions"]
      ];
      pnFile["places"] = [...pnFile["places"], ...currentJunction["places"]];
      pnFile["arcs"] = [...pnFile["arcs"], ...currentJunction["arcs"]];
      pnFile["labels"].add(currentJunction["labels"]);
      pnFile["outputPlaces"].addAll(outputPlaces);
    }
    // shift junctionConnections to previousStep's considerations.
    oldJunctions = newJunctions;
    newJunctions = [];
  }
  Map<String, dynamic> stringDrawnPoints = {
    "transitions": json.encode(pnFile["transitions"]),
    "places": json.encode(pnFile["places"]),
    "arcs": json.encode(pnFile["arcs"]),
    "labels": json.encode(pnFile["labels"]),
    "outputPlaces": json.encode(pnFile["outputPlaces"])
  };
  return stringDrawnPoints;
}

getOutputPlaces(Map<String, dynamic> currentJunction) {
  List<Place> outputPlaces = [];
  // goes through places from generated junction and finds the output row
  List<Place> places = currentJunction["places"];
  // grabbing the first place to get a left-most limit.
  var initPoint = currentJunction["places"][0].point;
  outputPlaces =
      places.where((index) => index.point.dx > initPoint.dx).toList();
  return outputPlaces;
}

getJunction(x, y, String junctionShape, List<DrawnJunction> prevJunctions,
    String serialNum, int stepNum) {
  // return string for the new four-port junction to add into file.
  Map<String, String> junctionTxt;
  if (junctionShape == "4-Port") {
    junctionTxt = fourPortTxt;
  } else if (junctionShape == "3-Port") {
    junctionTxt = threePortTxt;
  } else if (junctionShape == "2-Port") {
    junctionTxt = twoPortTxt;
  } else {
    Error();
  }
  var transitions = jsonDecode(junctionTxt["transitions"]);
  var places = jsonDecode(junctionTxt["places"]);
  var arcs = jsonDecode(junctionTxt["arcs"]);
  List<Map<String, dynamic>> connections = [];
  List<int> index = [];
  // create a list of drawnJunctions connected to this junction
  for (int l = 0; l < prevJunctions.length; l++) {
    for (int c = 0; c < prevJunctions[l].junctionConnections.length; c++) {
      if (prevJunctions[l].junctionConnections[c].junction == serialNum) {
        // the drawnJunction itself will give us the outport and inport information
        connections.add({
          "connection": prevJunctions[l].junctionConnections[c],
          "drawnJunction": prevJunctions[l]
        });
        // crutially, l will give us the y-axis index to be drawn with.
        index.add(l);
      }
    }
  }
  prevJunctions.forEach((junction) => junction.junctionConnections
      .where((connection) => connection.junction == serialNum));

  List<DrawnPoint> DrawnTransitions = List.generate(
      transitions.length, (index) => DrawnPoint.fromJson(transitions[index]));
  List<Place> DrawnPlaces =
      List.generate(places.length, (index) => Place.fromJson(places[index]));
  List<DrawnArc> DrawnArcs =
      List.generate(arcs.length, (index) => DrawnArc.fromJson(arcs[index]));

  // shift all elements points by an x and y value which is prescribed.
  // for some reason the y value is itterated instead of the x value?
  if (junctionShape == "3-Port") {
    DrawnPlaces.forEach((element) {
      element.point = Offset(element.point.dx + 50, element.point.dy + 50);
    });
    DrawnTransitions.forEach((element) {
      element.point = Offset(element.point.dx + 50, element.point.dy + 50);
    });
    DrawnArcs.forEach((element) {
      element.point1 = Offset(element.point1.dx + 50, element.point1.dy + 50);
      element.point2 = Offset(element.point2.dx + 50, element.point2.dy + 50);
    });
  }
  if (junctionShape == "2-Port") {
    DrawnPlaces.forEach((element) {
      element.point = Offset(element.point.dx + 25, element.point.dy - 50);
    });
    DrawnTransitions.forEach((element) {
      element.point = Offset(element.point.dx + 25, element.point.dy - 50);
    });
    DrawnArcs.forEach((element) {
      element.point1 = Offset(element.point1.dx + 25, element.point1.dy - 50);
      element.point2 = Offset(element.point2.dx + 25, element.point2.dy - 50);
    });
  }
  DrawnTransitions.forEach((element) {
    element.point = Offset(element.point.dx + x, element.point.dy + y);
  });
  DrawnPlaces.forEach((element) {
    element.point = Offset(element.point.dx + x, element.point.dy + y);
  });
  DrawnArcs.forEach((element) {
    element.point1 = Offset(element.point1.dx + x, element.point1.dy + y);
    element.point2 = Offset(element.point2.dx + x, element.point2.dy + y);
    if (element.point1.dx == DrawnPlaces.first.point.dx) {
      element.weight = 1;
    } /*else if (junctionShape == "3-Port") {
      element.weight = element.weight * 0.33;
    } else if (junctionShape == "4-Port") {
      element.weight = element.weight * 0.5;
    }*/
  });
  var initPoint = DrawnPlaces.first.point;
  var labelPoint = Offset(initPoint.dx + 100, initPoint.dy - 25);
  // add a cheeky label into the mix.
  DrawnLabel label = DrawnLabel(labelPoint, junctionShape + serialNum);
  // used to calibrate connection
  // [[Transitions for Connection], [Arcs for Connection]]
  // this section currently only works for a couple of connected four port cases.
  var connectingArcs =
      drawConnections(connections, index, x, y, initPoint, stepNum);

  DrawnTransitions.addAll(connectingArcs[0]);
  DrawnArcs.addAll(connectingArcs[1]);

  // convert back into a map
  Map<String, dynamic> stringDrawnPoints = {
    "transitions": DrawnTransitions,
    "places": DrawnPlaces,
    "arcs": DrawnArcs,
    "labels": label
  };

  return stringDrawnPoints;
}

drawConnections(List<Map<String, dynamic>> connections, List<int> index, x, y,
    Offset initPoint, int stepNum) {
  List<DrawnArc> connectingArcs = [];
  List<DrawnPoint> transitions = [];
  // add transitions to new connection
  if (connections.length != 0) {
    // don't add the places for the first junction
    for (int l = 0; l < 4; l++) {
      var pos = l * 75;
      connectingArcs.add(DrawnArc(
          Offset(initPoint.dx - 25, initPoint.dy + pos),
          Offset(initPoint.dx, initPoint.dy + pos),
          Color.fromARGB(255, 0, 0, 0),
          1));
      connectingArcs.add(DrawnArc(
          Offset(initPoint.dx - 25, initPoint.dy + pos + 25),
          Offset(initPoint.dx, initPoint.dy + pos + 25),
          Color.fromARGB(255, 0, 0, 0),
          1));
    }
  }
  // now draw the arcs to connect these up
  for (int a = 0; a < connections.length; a++) {
    var arc1point1;
    var arc1point2;
    var arc2point1;
    var arc2point2;
    // port being connected from
    var outputPort = connections[a]["connection"].outPort;
    // port being connected to
    var inputPort = connections[a]["connection"].inPort;
    var connectionSerial = connections[a]["connection"].junction;
    // we need to calibrate the connection's y-axis info.
    // index a gives an integer value for the offset (in blocks of 300px) of the junction in the y axis.
    var yCalib = 200 + (index[a] * 300) - initPoint.dy;
    // brute forcing correct connections here
    switch (outputPort) {
      case 1:
        arc1point1 = Offset(initPoint.dx - 75, initPoint.dy + yCalib);
        arc2point1 = Offset(initPoint.dx - 75, initPoint.dy + 25 + yCalib);
        break;
      case 2:
        arc1point1 = Offset(initPoint.dx - 75, initPoint.dy + 75 + yCalib);
        arc2point1 = Offset(initPoint.dx - 75, initPoint.dy + 100 + yCalib);
        break;
      case 3:
        arc1point1 = Offset(initPoint.dx - 75, initPoint.dy + 150 + yCalib);
        arc2point1 = Offset(initPoint.dx - 75, initPoint.dy + 175 + yCalib);
        break;
      case 4:
        arc1point1 = Offset(initPoint.dx - 75, initPoint.dy + 225 + yCalib);
        arc2point1 = Offset(initPoint.dx - 75, initPoint.dy + 250 + yCalib);
        break;
    }
    switch (inputPort) {
      case 1:
        arc1point2 = Offset(initPoint.dx - 25, initPoint.dy);
        arc2point2 = Offset(initPoint.dx - 25, initPoint.dy + 25);
        transitions.add(DrawnPoint(Offset(initPoint.dx - 25, initPoint.dy),
            "Transition", Color.fromARGB(255, 0, 0, 0)));
        transitions.add(DrawnPoint(Offset(initPoint.dx - 25, initPoint.dy + 25),
            "Transition", Color.fromARGB(255, 0, 0, 0)));
        break;
      case 2:
        arc1point2 = Offset(initPoint.dx - 25, initPoint.dy + 75);
        arc2point2 = Offset(initPoint.dx - 25, initPoint.dy + 100);
        transitions.add(DrawnPoint(Offset(initPoint.dx - 25, initPoint.dy + 75),
            "Transition", Color.fromARGB(255, 0, 0, 0)));
        transitions.add(DrawnPoint(
            Offset(initPoint.dx - 25, initPoint.dy + 100),
            "Transition",
            Color.fromARGB(255, 0, 0, 0)));
        break;
      case 3:
        arc1point2 = Offset(initPoint.dx - 25, initPoint.dy + 150);
        arc2point2 = Offset(initPoint.dx - 25, initPoint.dy + 175);
        transitions.add(DrawnPoint(
            Offset(initPoint.dx - 25, initPoint.dy + 150),
            "Transition",
            Color.fromARGB(255, 0, 0, 0)));
        transitions.add(DrawnPoint(
            Offset(initPoint.dx - 25, initPoint.dy + 175),
            "Transition",
            Color.fromARGB(255, 0, 0, 0)));
        break;
      case 4:
        arc1point2 = Offset(initPoint.dx - 25, initPoint.dy + 225);
        arc2point2 = Offset(initPoint.dx - 25, initPoint.dy + 250);
        transitions.add(DrawnPoint(
            Offset(initPoint.dx - 25, initPoint.dy + 225),
            "Transition",
            Color.fromARGB(255, 0, 0, 0)));
        transitions.add(DrawnPoint(
            Offset(initPoint.dx - 25, initPoint.dy + 250),
            "Transition",
            Color.fromARGB(255, 0, 0, 0)));
        break;
    }

    // var arcWeights = stepNum;
    connectingArcs
        .add(DrawnArc(arc1point1, arc1point2, Color.fromARGB(255, 0, 0, 0), 1));
    connectingArcs
        .add(DrawnArc(arc2point1, arc2point2, Color.fromARGB(255, 0, 0, 0), 1));
  }
  return [transitions, connectingArcs];
}
