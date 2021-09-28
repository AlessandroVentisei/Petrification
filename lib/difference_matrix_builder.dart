import 'package:flutter/material.dart';
import 'package:matrix2d/matrix2d.dart';

List<dynamic> differenceMatrixBuilder(
    matrices, selectedShape, drawnPoints, currentArc) {
  Matrix2d m2d = Matrix2d();
  List<dynamic> diffMatrix =
      m2d.zeros(matrices["Place"], matrices["Transition"]);
  List<dynamic> diffMatrixMinus = diffMatrix;
  List<dynamic> diffMatrixPlus = diffMatrixMinus;
  List<dynamic> loc;
  //This function will first compare the current arc to drawn places to find points connected.
  //currentArc.point1 must = a drawnPoints.point
  loc = pointFinder(drawnPoints, currentArc);
  if (loc[2] == "Place") {
    diffMatrixMinus[loc[0]][loc[1]] = 1;
  }
  if (loc[2] == "Transition") {
    diffMatrixPlus[loc[0]][loc[1]] = 1;
  }

  //now return both matrices for storage, and import them for reuse...
  diffMatrix = m2d.subtraction(diffMatrixPlus, diffMatrixMinus);
  return diffMatrix;
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
