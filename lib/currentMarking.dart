import 'package:drawing_app/difference_matrix_builder.dart';
import 'package:flutter/material.dart';

List<int> currentMarkingBuilder(drawnPoints, matrices) {
  Offset tokenCoord;
  int place;
  List<int> currentMarking = List.filled(matrices["Place"], 0);
  for (int i = 0; i < drawnPoints.length; ++i) {
    if (drawnPoints[i].shape == "Token") {
      tokenCoord = drawnPoints[i].point;
      for (int l = 0; l < drawnPoints.length; ++l) {
        if (drawnPoints[l].shape == "Place" &&
            drawnPoints[l].point == tokenCoord) {
          place = placeFinder(drawnPoints, tokenCoord);
          currentMarking[place] = 1;
        }
      }
    }
  }
  return currentMarking;
}
