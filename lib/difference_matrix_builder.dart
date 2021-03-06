import 'package:matrix2d/matrix2d.dart';

//This is where the difference matrix is contructed after each arc is drawn.
//Information on how this is done: https://www.techfak.uni-bielefeld.de/~mchen/BioPNML/Intro/MRPN.html
//Essential to advancement of PN is the difference matrix, once confirmed it may be used for each advancement.

List<dynamic> differenceMatrixBuilder(
    matrices, selectedShape, drawnArcs, drawnPoints) {
  Matrix2d m2d = Matrix2d();
  List<dynamic> diffMatrix =
      m2d.zeros(matrices["Place"], matrices["Transition"]);
  List<dynamic> diffMatrixPlus =
      m2d.zeros(matrices["Place"], matrices["Transition"]);
  List<dynamic> diffMatrixMinus =
      m2d.zeros(matrices["Place"], matrices["Transition"]);

  for (int i = 0; i < drawnArcs.length; i++) {
    differenceMatrixBuilderCurrentArc(matrices, selectedShape, drawnPoints,
        drawnArcs[i], diffMatrixPlus, diffMatrixMinus);
  }
  diffMatrix = m2d.subtraction(diffMatrixPlus, diffMatrixMinus);
  return diffMatrix;
}

List<dynamic> differenceMatrixBuilderCurrentArc(matrices, selectedShape,
    drawnPoints, currentArc, diffMatrixPlus, diffMatrixMinus) {
  List<dynamic> loc;
  //This function will first compare the current arc to drawn places to find points connected.
  //currentArc.point1 must = a drawnPoints.point
  loc = pointFinder(drawnPoints, currentArc);
  if (loc[2] == "Place") {
    diffMatrixMinus[loc[0]][loc[1]] += 1;
  }
  if (loc[2] == "Transition") {
    diffMatrixPlus[loc[1]][loc[0]] += 1;
  }
  return [diffMatrixMinus, diffMatrixPlus];
}

List<dynamic> pointFinder(drawnPoints, currentArc) {
  int outputPointer = 0;
  int inputPointer = 0;
  int numPlaces = 0;
  int numTrans = 0;
  String outputShape;
  for (int i = 0; i < drawnPoints.length; ++i) {
    if (drawnPoints[i].shape == "Place") {
      numPlaces += 1;
      if (currentArc.point1 == drawnPoints[i].point) {
        outputPointer = numPlaces - 1;
        outputShape = drawnPoints[i].shape;
      }
      if (currentArc.point2 == drawnPoints[i].point) {
        inputPointer = numPlaces - 1;
      }
    }
    if (drawnPoints[i].shape == "Transition") {
      numTrans += 1;
      if (currentArc.point1 == drawnPoints[i].point) {
        outputPointer = numTrans - 1;
        outputShape = drawnPoints[i].shape;
      }
      if (currentArc.point2 == drawnPoints[i].point) {
        inputPointer = numTrans - 1;
      }
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
