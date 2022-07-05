import 'package:flutter/material.dart';
import 'package:polyscript/helper.dart';
import 'package:polyscript/model/user_model.dart';
import '../line_widget.dart';

class CursorPainter extends CustomPainter {
  final TextPainter lineTextPainter;
  final List<User> users;

  late TextPainter usernamePainter;
  late Paint backgroundPaint;
  late Offset userCursorPosition;

  double? animationValue;
  final double textOffset;

  final cursorTextStyle = const TextStyle(fontSize: 12, height: 1, fontFamily: "Roboto");
  final usernameLabelPadding = 6;

  CursorPainter(this.lineTextPainter, this.users, this.textOffset, {this.animationValue}) {
    backgroundPaint = Paint();

    usernamePainter = TextPainter(
      text: TextSpan(text: "", style: cursorTextStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var user in users) {
      initParamsForUser(user);
      drawCursor(canvas, size, user);
    }
  }

  void initParamsForUser(User user) {
    usernamePainter.text = TextSpan(text: user.name, style: cursorTextStyle);
    usernamePainter.layout();

    userCursorPosition = lineTextPainter.getOffsetForCaret(
      TextPosition(offset: user.cursorPosition.x),
      Rect.zero,
    );

    backgroundPaint.color = user.color;
  }

  void drawCursor(Canvas canvas, Size size, User user) {
    drawCursorBackground(canvas);
    drawCursorUsername(canvas);
  }

  void drawCursorBackground(Canvas canvas) {
    var background = roundRect(
      Rect.fromLTWH(
        userCursorPosition.dx + LineWidget.leftTextOffset,
        0,
        usernamePainter.width + usernameLabelPadding * 2,
        20.0,
      ),
      [6, 0, 6, 6],
    );

    var cursor = roundRect(
      Rect.fromLTWH(
        userCursorPosition.dx + LineWidget.leftTextOffset,
        10,
        2.0,
        userCursorPosition.dy + 30.0,
      ),
      [0, 1, 0, 1],
    );

    canvas.drawRRect(background, backgroundPaint);
    canvas.drawRRect(cursor, backgroundPaint);
  }

  void drawCursorUsername(Canvas canvas) {
    usernamePainter.paint(
      canvas,
      Offset(
          userCursorPosition.dx +
              LineWidget.lineIndexingWidth +
              LineWidget.spaceBetweenIndexAndText +
              usernameLabelPadding,
          4),
    );
  }

  //TODO: использовать для отображения курсора локального пользователя
  void drawLocalUserCursor(Canvas canvas) {
    if (animationValue != null) {
      final cursorPaint = Paint()..color = Colors.black.withOpacity(animationValue!);
      var cursorOffset = lineTextPainter.getOffsetForCaret(
        TextPosition(offset: userCursorPosition.dx.toInt()),
        Rect.zero,
      );
      canvas.drawRRect(
        roundRect(
            Rect.fromLTWH(
              cursorOffset.dx + LineWidget.leftTextOffset,
              cursorOffset.dy + textOffset,
              2,
              20,
            ),
            [1, 1, 1, 1]),
        cursorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
