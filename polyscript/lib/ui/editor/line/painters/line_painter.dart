import 'package:flutter/material.dart';
import '../line_widget.dart';

class LinePainter extends CustomPainter {
  final TextPainter textPainter;
  final TextPainter indexPainter;
  final double topTextOffset;

  LinePainter(this.indexPainter, this.textPainter, this.topTextOffset);

  @override
  void paint(Canvas canvas, Size size) {
    drawLineIndex(canvas);
    drawText(canvas);
  }

  void drawLineIndex(Canvas canvas) {
    indexPainter.paint(canvas, Offset(LineWidget.lineIndexingWidth - indexPainter.width, topTextOffset));
  }

  void drawText(Canvas canvas) {
    textPainter.paint(canvas, Offset(LineWidget.leftTextOffset, topTextOffset));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
