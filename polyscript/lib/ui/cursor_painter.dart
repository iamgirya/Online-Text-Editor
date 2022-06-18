import 'dart:math';

import 'package:flutter/material.dart';
import '../model/user.dart';

class CursorPainter extends CustomPainter {
  CursorPainter(this.users, {this.scrollOffset = 0});

  final List<User> users;
  final double scrollOffset;

  @override
  void paint(Canvas canvas, Size size) {
    for (var user in users) {
      drawCursor(canvas, size, user);
    }
  }

  void drawCursor(Canvas canvas, Size size, User user) {
    var paint = Paint();
    paint.color = user.color;

    var text = TextPainter(
      text: TextSpan(
        text: user.name,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
          fontFamily: "Roboto",
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    text.layout();

    var background = roundRect(
        Rect.fromLTWH(
          user.cursorPosition.x.toDouble(),
          max(0, user.cursorPosition.y.toDouble() - 20 - scrollOffset),
          text.width + 12,
          20.0,
        ),
        [6, 0, 6, 6]);

    var cursor = roundRect(
        Rect.fromLTWH(
          user.cursorPosition.x.toDouble(),
          max(6, user.cursorPosition.y.toDouble() - scrollOffset),
          2.0,
          min(20.0, max(0, user.cursorPosition.y.toDouble() - scrollOffset - 6 + 20)),
        ),
        [0, 1, 0, 1]);

    canvas.drawRRect(background, paint);
    canvas.drawRRect(cursor, paint);

    text.paint(
        canvas,
        Offset(
          user.cursorPosition.x.toDouble() + 6,
          max(5, user.cursorPosition.y.toDouble() - 20 - scrollOffset + 5),
        ));
  }

  RRect roundRect(Rect rect, List<double> corners) {
    return RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(corners[0]),
      bottomLeft: Radius.circular(corners[1]),
      topRight: Radius.circular(corners[2]),
      bottomRight: Radius.circular(corners[3]),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
