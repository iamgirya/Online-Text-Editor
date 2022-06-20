import 'package:flutter/material.dart';

RRect roundRect(Rect rect, List<double> corners) {
  return RRect.fromRectAndCorners(
    rect,
    topLeft: Radius.circular(corners[0]),
    bottomLeft: Radius.circular(corners[1]),
    topRight: Radius.circular(corners[2]),
    bottomRight: Radius.circular(corners[3]),
  );
}
