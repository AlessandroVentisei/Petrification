import 'package:drawing_app/drawn_line.dart';
import 'package:ml_linalg/matrix.dart';

simulateNet(List<Place> drawnPlaces, List<DrawnPoint> drawnPoints,
    List<List<List<double>>> diffMatrix) {
  // get current amplitude numbers
  final amplitudeMarking = List<double>.generate(
      drawnPlaces.length, (index) => drawnPlaces[index].tokens[0].toDouble());
  // get current phase numbers
  final phaseMarking = List<double>.generate(
      drawnPlaces.length, (index) => drawnPlaces[index].tokens[1].toDouble());
  final objectMatrix = {
    "Place": drawnPlaces.length,
    "Transition": drawnPoints.length
  };
  // live transitions only calculated using amplitude Tokens.
  List<double> liveTransitions =
      liveTranstisions(amplitudeMarking, diffMatrix[0], objectMatrix);
  // get newMatrix marking using new matrix operation function
  var newAmplitudeMatrix =
      (matrixMultiplication([liveTransitions], diffMatrix[0]) +
              Matrix.fromList([amplitudeMarking]))
          .asFlattenedList;
  var newPhaseMatrix = (matrixMultiplication([liveTransitions], diffMatrix[1]) +
          Matrix.fromList([phaseMarking]))
      .asFlattenedList;
  // this is where we can add the logic to return a newMatrix from enabled transitions with a second differenceMatrix for phase relationships...
  // get newMarking as flat list for rest of program
  for (int i = 0; i < drawnPlaces.length; i++) {
    drawnPlaces[i].tokens[0] = newAmplitudeMatrix[i];
    drawnPlaces[i].tokens[1] = newPhaseMatrix[i];
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
