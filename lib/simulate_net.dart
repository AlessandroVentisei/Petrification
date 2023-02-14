import 'dart:io';
import 'package:drawing_app/drawn_line.dart';

simulateNet(List<Place> drawnPlaces, List<DrawnPoint> drawnPoints,
    List<List<num>> diffMatrix) {
  final marking = List<num>.generate(
      drawnPlaces.length, (index) => drawnPlaces[index].tokens);
  final objectMatrix = {
    "Place": drawnPlaces.length,
    "Transition": drawnPoints.length
  };
  List<int> liveTransitions =
      liveTranstisions(marking, diffMatrix, objectMatrix);
  final newMarking = List.generate(
      marking.length,
      (i) =>
          (matrixMultiplication(liveTransitions, diffMatrix))[i] + marking[i]);
  print("Next Marking: " + newMarking.toString());
  for (int i = 0; i < drawnPlaces.length; i++) {
    drawnPlaces[i].tokens = newMarking[i];
  }
  return drawnPlaces;
}

List<num> matrixMultiplication(m1, m2) {
  List<num> multiple = List.generate(m2.length, (index) => 0);
  for (int i = 0; i < m2.length; i++) {
    for (int j = 0; j < m1.length; j++) {
      multiple[i] += (m1[j] * m2[i][j]);
    }
  }
  return multiple;
}

List<int> liveTranstisions(currentMarking, diffMatrix, matrices) {
  // check if tokens are present in the current marking to enable transitions.
  // enabled if a place contains enough tokens to prevent the difference matrix from outputting any negative values.
  // List<int> liveTransitions = List.filled((matrices["Transition"]), 0);
  List<List<num>> conditionalMatrix = List.generate(
      diffMatrix[0].length,
      (i) => List.generate(currentMarking.length,
          (j) => (currentMarking[j] + diffMatrix[j][i])));
  List<int> liveTransitions = List.generate((matrices["Transition"]), (index) {
    var transitionEnabled = conditionalMatrix[index].singleWhere(
      (element) {
        return element < 0;
      },
      orElse: () => 1,
    );
    if (transitionEnabled == 1) {
      print("transition " + index.toString() + "enabled");
      return 1;
    } else {
      return 0;
    }
  });
  return liveTransitions;
}

int checkIfEnabled(List<num> currentRow) {
  var disabledSignal = currentRow.where((element) => element < 0);
  if (disabledSignal.length > 0) {
    return 1;
  } else {
    return 0;
  }
}
