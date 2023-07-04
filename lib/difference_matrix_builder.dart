import 'package:drawing_app/drawn_line.dart';

//This is where the difference matrix is contructed after each arc is drawn.
//Information on how this is done: https://www.techfak.uni-bielefeld.de/~mchen/BioPNML/Intro/MRPN.html
//Essential to advancement of PN is the difference matrix, once confirmed it may be used for each advancement.

List<List<List<double>>> differenceMatrixBuilder(
    selectedShape, drawnArcs, drawnPoints, drawnPlaces) {
  // integrate drawnPlaces with the differenceMatrixBuilder.
  final objectMatrix = {
    "Place": drawnPlaces.length,
    "Transition": drawnPoints.length
  };
  List<List<num>> diffMatrixPlus = List.generate(objectMatrix["Place"],
      (p) => List.generate(objectMatrix["Transition"], (t) => 0.0));
  List<List<num>> diffMatrixMinus = List.generate(objectMatrix["Place"],
      (p) => List.generate(objectMatrix["Transition"], (t) => 0.0));

  List<List<num>> phaseDiffMatrixPlus = List.generate(objectMatrix["Place"],
      (p) => List.generate(objectMatrix["Transition"], (t) => 0.0));
  List<List<num>> phaseDiffMatrixMinus = List.generate(objectMatrix["Place"],
      (p) => List.generate(objectMatrix["Transition"], (t) => 0.0));

  for (int i = 0; i < drawnArcs.length; i++) {
    differenceMatrixBuilderCurrentArc(
        objectMatrix,
        selectedShape,
        drawnPoints,
        drawnPlaces,
        drawnArcs[i],
        diffMatrixPlus,
        diffMatrixMinus,
        phaseDiffMatrixPlus,
        phaseDiffMatrixMinus);
  }
  List<List<double>> diffMatrix = List.generate(
      objectMatrix["Place"],
      (p) => List.generate(objectMatrix["Transition"],
          (t) => (diffMatrixPlus[p][t] - diffMatrixMinus[p][t]).toDouble()));

  List<List<double>> phaseDiffMatrix = List.generate(
      objectMatrix["Place"],
      (p) => List.generate(objectMatrix["Transition"],
          (t) => (phaseDiffMatrixPlus[p][t]).toDouble()));
  return [diffMatrix, phaseDiffMatrix];
}

List<dynamic> differenceMatrixBuilderCurrentArc(
    matrices,
    selectedShape,
    drawnPoints,
    List<Place> drawnPlaces,
    DrawnArc currentArc,
    List<List<num>> diffMatrixPlus,
    List<List<num>> diffMatrixMinus,
    List<List<num>> phaseDiffMatrixPlus,
    List<List<num>> phaseDiffMatrixMinus) {
  List<dynamic> loc;
  //This function will first compare the current arc to drawn places to find points connected.
  //currentArc.point1 must = a drawnPoints.point
  loc = pointFinder(drawnPoints, drawnPlaces, currentArc);
  if (loc[2] == "Place") {
    diffMatrixMinus[loc[0]][loc[1]] =
        diffMatrixMinus[loc[0]][loc[1]] + currentArc.amplitudeWeight;
  }
  if (loc[2] == "Transition") {
    diffMatrixPlus[loc[1]][loc[0]] =
        diffMatrixPlus[loc[1]][loc[0]] + currentArc.amplitudeWeight;
    phaseDiffMatrixPlus[loc[1]][loc[0]] += currentArc.phaseWeight;
  }
  return [
    diffMatrixMinus,
    diffMatrixPlus,
    phaseDiffMatrixPlus,
    phaseDiffMatrixMinus
  ];
}

List<dynamic> pointFinder(drawnPoints, drawnPlaces, currentArc) {
  int outputPointer = 0;
  int inputPointer = 0;
  String outputShape = '';
  // this loops through the points drawn and gives the placeNum
  // and transition num of the arc
  for (int i = 0; i < drawnPlaces.length; i++) {
    if (currentArc.point1 == drawnPlaces[i].point) {
      outputPointer = i;
      outputShape = "Place";
    }
    if (currentArc.point2 == drawnPlaces[i].point) {
      inputPointer = i;
    }
  }
  for (int i = 0; i < drawnPoints.length; i++) {
    if (currentArc.point1 == drawnPoints[i].point) {
      outputPointer = i;
      outputShape = "Transition";
    }
    if (currentArc.point2 == drawnPoints[i].point) {
      inputPointer = i;
    }
  }
  return [outputPointer, inputPointer, outputShape];
}

int placeFinder(drawnPoints, currentPoint) {
  int outputPointer = 0;
  int numPlaces = 0;
  for (int i = 0; i < drawnPoints.length; ++i) {
    if (drawnPoints[i].shape == "Place") {
      numPlaces += 1;
      if (currentPoint == drawnPoints[i].point) {
        outputPointer = numPlaces - 1;
      }
    }
  }
  return outputPointer;
}

int placeFinderBySequence(drawnPoints, currentPoint) {
  int outputPointer = 0;
  int numPlaces = 0;
  for (int i = 0; i < drawnPoints.length; ++i) {
    if (drawnPoints[i].shape == "Place") {
      if (currentPoint == numPlaces) {
        outputPointer = i;
      }
      numPlaces += 1;
    }
  }
  return outputPointer;
}

int tokenFinder(drawnPoints, currentPoint) {
  int outputPointer = 0;
  int numTokens = 0;
  for (int i = 0; i < drawnPoints.length; ++i) {
    if (drawnPoints[i].shape == "Token") {
      numTokens += 1;
      if (currentPoint == drawnPoints[i].point) {
        outputPointer = numTokens - 1;
      }
    }
  }
  return outputPointer;
}
