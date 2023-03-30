import 'dart:html';
import 'dart:io';
import 'package:drawing_app/drawn_line.dart';
import 'package:ml_linalg/matrix.dart';

simulateNet(List<Place> drawnPlaces, List<DrawnPoint> drawnPoints,
    List<List<double>> diffMatrix) {
  final marking = List<double>.generate(
      drawnPlaces.length, (index) => drawnPlaces[index].tokens);
  final objectMatrix = {
    "Place": drawnPlaces.length,
    "Transition": drawnPoints.length
  };
  List<double> liveTransitions =
      liveTranstisions(marking, diffMatrix, objectMatrix);
  // get newMatrix marking using new matrix operation function
  var newMatrix = matrixMultiplication([liveTransitions], diffMatrix) +
      Matrix.fromList([marking]);
  // get newMarking as flat list for rest of program
  final newMarking = newMatrix.asFlattenedList;
  for (int i = 0; i < drawnPlaces.length; i++) {
    drawnPlaces[i].tokens = newMarking[i];
  }
  return drawnPlaces;
}

Matrix matrixMultiplication(m1, m2) {
  final matrix1 = Matrix.fromList(m1);
  final matrix2 = Matrix.fromList(m2).transpose();
  final multiple = matrix1 * matrix2;
  return multiple;
}

List<double> liveTranstisions(
    List<double> currentMarking, List<List<double>> diffMatrix, matrices) {
  // check if tokens are present in the current marking to enable transitions.
  // enabled if a place contains enough tokens to prevent the difference matrix from outputting any negative values.
  List<double> liveTransitions = List.filled((matrices["Transition"]), 0);
  List<List<double>> conditionalMatrix = List.generate(
      diffMatrix[0].length,
      (i) => List.generate(currentMarking.length,
          (j) => (currentMarking[j] + diffMatrix[j][i])));

  for (var index = 0; index < conditionalMatrix.length; index++) {
    var transitionEnabled = conditionalMatrix[index].singleWhere(
      (element) => element < 0,
      orElse: () => 1,
    );
    if (transitionEnabled == 1) {
      liveTransitions[index] = 1.0;
    } else {
      liveTransitions[index] = 0.0;
    }
  }
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
