import 'dart:math';
import 'package:flutter/material.dart';
import 'package:polyscript/model/user_model.dart';
import '../line_widget.dart';

class SelectionPainter extends CustomPainter {
  final TextPainter lineTextPainter;
  final int lineIndex;
  List<User> users;

  late Offset startSelectionPosition;
  late Offset endSelectionPosition;
  late Offset textOffset;
  late int selectedSublinesCount;

  late Paint backgroundPaint = Paint();

  SelectionPainter(this.lineTextPainter, this.users, this.lineIndex) {
    textOffset = Offset(
      LineWidget.leftTextOffset,
      users.indexWhere((user) => user.cursorPosition.y == lineIndex) != -1 ? 20 : 0,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var user in users) {
      if (isLineInUserSelection(user)) {
        initParamsForUser(user, size);
        drawSelection(canvas, size);
      }
    }
  }

  bool isLineInUserSelection(User user) {
    return user.selection.intersect(
          Selection(
            Point(0, lineIndex),
            Point(lineTextPainter.text!.toPlainText().length - 1, lineIndex),
          ),
        ) &&
        !user.selection.isEmpty;
  }

  void initParamsForUser(User user, Size size) {
    backgroundPaint.color = user.color.withOpacity(0.25);
    startSelectionPosition = getStartSelectionPosition(user);
    endSelectionPosition = getEndSelectionPosition(user, size);
    selectedSublinesCount = (endSelectionPosition.dy - startSelectionPosition.dy) ~/ 20 + 1;
  }

  Offset getStartSelectionPosition(User user) {
    if (user.selection.start.y < lineIndex) {
      return textOffset;
    } else if (user.selection.start.y == lineIndex) {
      return lineTextPainter.getOffsetForCaret(TextPosition(offset: user.selection.start.x), Rect.zero) + textOffset;
    } else {
      return Offset.zero;
    }
  }

  Offset getEndSelectionPosition(User user, Size size) {
    if (user.selection.end.y > lineIndex) {
      return Offset(size.width, size.height - 20);
    } else if (user.selection.end.y == lineIndex) {
      return lineTextPainter.getOffsetForCaret(TextPosition(offset: user.selection.end.x), Rect.zero) + textOffset;
    } else {
      return Offset.zero;
    }
  }

  void drawSelection(Canvas canvas, Size size) {
    if (selectedSublinesCount == 1) {
      canvas.drawRect(
          Rect.fromLTRB(startSelectionPosition.dx, startSelectionPosition.dy, endSelectionPosition.dx,
              endSelectionPosition.dy + 20),
          backgroundPaint);
    } else {
      canvas.drawRect(
        Rect.fromLTWH(startSelectionPosition.dx, startSelectionPosition.dy, size.width, 20),
        backgroundPaint,
      );

      for (int i = 1; i < selectedSublinesCount - 1; i++) {
        canvas.drawRect(
          Rect.fromLTRB(0, startSelectionPosition.dy + i * 20, size.width, startSelectionPosition.dy + i * 20 + 20),
          backgroundPaint,
        );
      }

      canvas.drawRect(
        Rect.fromLTRB(0, endSelectionPosition.dy, endSelectionPosition.dx, endSelectionPosition.dy + 20),
        backgroundPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
