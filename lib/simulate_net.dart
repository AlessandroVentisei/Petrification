import 'dart:io';

import 'package:drawing_app/drawn_line.dart';
import 'package:flutter/material.dart';
import 'package:matrix2d/matrix2d.dart';

simulateNet(List<Place> drawnPlaces, diffMatrix, matrices) {
  final marking = List<num>.generate(
      drawnPlaces.length, (index) => drawnPlaces[index].tokens);
  List<int> liveTransitions = liveTranstisions(marking, diffMatrix, matrices);
  //NextMarking = ([TransitionMatrix]*[DiffMatrix]) + Marking
  List<dynamic> newMarking = Matrix2d()
      .addition(matrixMultiplication(liveTransitions, diffMatrix), marking);
  print("Next Marking: " + newMarking.toString());
  for (int i = 0; i < drawnPlaces.length; i++) {
    drawnPlaces[i].tokens = newMarking[i];
  }
  return drawnPlaces;
}

List<int> matrixMultiplication(m1, m2) {
  List<int> multiple = List.generate(m2.length, (index) => 0);
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
  final m2d = Matrix2d();
  List<int> liveTransitions = List.filled((matrices["Transition"]), 0);
  List<dynamic> conditionalMatrix =
      m2d.zeros(diffMatrix[0].length, currentMarking.length);
  // List<int> conditionalMatrix = List.filled(matrices["Place"], 0);
  for (var i = 0; i < diffMatrix[0].length; i++) {
    for (var j = 0; j < currentMarking.length; j++) {
      conditionalMatrix[i][j] = currentMarking[j] + diffMatrix[j][i];
    }
    if (checkIfEnabled(conditionalMatrix[i])) {
      print("Transition " + (i).toString() + " ENABLED");
      liveTransitions[i] = 1;
    } else {
      print("Transition " + (i).toString() + " DISABLED");
    }
  }
  return liveTransitions;
}

bool checkIfEnabled(currentRow) {
  for (var i = 0; i < currentRow.length; i++) {
    if (currentRow[i] < 0) {
      return false;
      //found a negative value in the current row -> transition not enabled.
    }
  }
  return true;
  //found no negative values in current row -> transition enabled.
}
