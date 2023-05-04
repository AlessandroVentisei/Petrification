import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'drawn_line.dart';

// given a list of output places we need to group these into junctions
List<Iterable<SfCartesianChart>> createPlotsFromOutputPlaces(
    BuildContext context,
    List<Place> drawnOutputPlaces,
    int scatteringItterations,
    List<DrawnLabel> labels) {
  // first row of the PN defined by initPoint
  Offset initPoint = drawnOutputPlaces.first.point;
  List<List<Place>> groupedByItteration = [];
  List<List<DrawnLabel>> orderedLabels = [];
  List<List<List<List<Place>>>> groupedByJunctionAndPort = [
    [[]]
  ];
  for (int i = 0; i < scatteringItterations; i++) {
    // junctions are placed in 300px blocks so we can group iterations using this
    groupedByItteration.add(drawnOutputPlaces
        .where((element) => element.point.dx == initPoint.dx + (i * 300))
        .toList());
    // add ordered junction labels for this scattering iteration
    orderedLabels.add(labels
        .where((element) => element.offset.dx == initPoint.dx + (i * 300) - 125)
        .toList());
    // now we should group by junction and port by checking how far appart the dy points are.
    // points are the same port if their dy are 25px apart.
    // points are the same junction if their dy are 50px apart.
    // if the point is futher away but still in line then it is a seperate junction and should have a new histogram with a label.
    Place currentPlace;
    Place nextPlace;
    // [ listOfItterations [ ListofJunctions [ [port1, port2], [port 1, port2], ... ] ] ]
    int port = 1;
    int junction = 0;
    if (groupedByItteration[i].isEmpty) {
      groupedByJunctionAndPort.removeLast();
      break;
    }
    for (int l = 0; l < groupedByItteration[i].length - 1; l++) {
      currentPlace = groupedByItteration[i][l];
      nextPlace = groupedByItteration[i][l + 1];
      if ((currentPlace.point.dy - nextPlace.point.dy) == -25 && port <= 4) {
        // insert pair of places in correct port
        groupedByJunctionAndPort[i][junction].add([currentPlace, nextPlace]);
        port++;
      } else if ((currentPlace.point.dy - nextPlace.point.dy) >= -50 &&
          port == 5) {
        // new junction in this itteration
        groupedByJunctionAndPort[i].add([]);
        junction++;
        port = 1;
      }
    }
    groupedByJunctionAndPort.add([[]]);
  }
  List<Iterable<SfCartesianChart>> histograms = [];
  for (int i = 0; i < groupedByJunctionAndPort.length; i++) {
    // mapping junctions from each itteration step into it's own plot.
    histograms.add(groupedByJunctionAndPort[i].map((e) => SfCartesianChart(
            primaryXAxis: CategoryAxis(title: AxisTitle(text: "Port Number")),
            primaryYAxis: NumericAxis(title: AxisTitle(text: "Token Count")),
            backgroundColor: Colors.white,
            tooltipBehavior: TooltipBehavior(enable: false),
            title: ChartTitle(
                text: orderedLabels[i][groupedByJunctionAndPort[i].indexOf(e)]
                    .name),
            series: <ChartSeries<List<Place>, int>>[
              ColumnSeries<List<Place>, int>(
                  dataSource: e,
                  xValueMapper: (List<Place> port, _) => e.indexOf(port) + 1,
                  yValueMapper: (List<Place> port, _) =>
                      port.first.tokens - port.last.tokens,
                  name: 'Gold',
                  color: Color.fromRGBO(8, 142, 255, 1))
            ])));
  }
  return histograms;
}
