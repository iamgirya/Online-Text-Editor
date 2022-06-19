import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:polyscript/ui/styles.dart';

class LineIndexPainter extends CustomPainter {
  late TextPainter textPainter;
  double scrollOffset = 0;

  LineIndexPainter() {
    textPainter = TextPainter(
      maxLines: null,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    var startIndex = scrollOffset ~/ 20;
    var endIndex = startIndex + (size.height / 20.0).ceil();

    var painterText = "";

    for (int i = startIndex; i <= endIndex; i++) {
      painterText += i.toString() + "\n";
    }

    textPainter.text = TextSpan(
      text: painterText,
      style: TextStyle(
        fontFamily: "Roboto",
        fontSize: 16,
        height: 1.25,
        color: Colors.grey.shade400,
      ),
    );

    textPainter.layout();

    textPainter.paint(canvas, Offset(size.width - textPainter.width, -(scrollOffset % 20)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
