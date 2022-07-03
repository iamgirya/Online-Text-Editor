import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polyscript/helper.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/ui/styles.dart';
import 'package:provider/provider.dart';
import '../../model/user_model.dart';

//виджет, отвечающий за отображение одной строки текста
class LineWidget extends StatefulWidget {
  final int index;
  final String text;
  final double lineWidth;

  const LineWidget({
    Key? key,
    required this.text,
    required this.index,
    required this.lineWidth,
  }) : super(key: key);

  static double baseHeight = 20;

  @override
  State<LineWidget> createState() => LineWidgetState();
}

class LineWidgetState extends State<LineWidget> with TickerProviderStateMixin {
  late TextPainter indexPainter;
  late TextPainter textPainter;
  late double lineHeight;
  var localUserLineIndex = -1;

  late Animation<double> animation;
  late AnimationController controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
  late EditorModel editor;
  late List<User> usersOnLine;

  void initPainters(String text, Selection? selection) {
    indexPainter = TextPainter(
      text: TextSpan(
        text: widget.index.toString(),
        style: indexStyle,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    indexPainter.layout(minWidth: 48, maxWidth: 48);

    //обновление выделения
    int? highlightStart;
    int? highlightEnd;
    if (selection != null) {
      if (selection.start.y > selection.end.y ||
          (selection.start.y == selection.end.y && selection.start.x > selection.end.x)) {
        selection = Selection(selection.end, selection.start);
      }
      if (selection.start.y < widget.index) {
        highlightStart = 0;
      } else if (selection.start.y == widget.index) {
        highlightStart = selection.start.x;
      }
      if (selection.end.y == widget.index) {
        highlightEnd = selection.end.x;
      } else if (selection.end.y > widget.index) {
        highlightEnd = text.length;
      }
    }

    if (highlightStart != null && highlightEnd != null) {
      textPainter = TextPainter(
        text: TextSpan(children: <TextSpan>[
          //перед выделением
          TextSpan(
            text: text.substring(0, highlightStart),
            style: textStyle,
          ),
          //выделение
          TextSpan(
            text: text.substring(highlightStart, highlightEnd),
            style: textStyleHighlight,
          ),
          //после выделения
          TextSpan(
            text: text.substring(highlightEnd),
            style: textStyle,
          ),
        ]),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      );
    } else {
      textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
      );
    }

    textPainter.layout(minWidth: widget.lineWidth - 80, maxWidth: widget.lineWidth - 80);
  }

  int getCursorOffset(Offset position) {
    var yOffset = usersOnLine.isEmpty ? 0 : 20;
    return textPainter.getPositionForOffset(Offset(position.dx, position.dy - yOffset)).offset;
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (localUserLineIndex == widget.index) {
        setState(() {});
      }
    });

    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
      reverseCurve: Curves.easeIn,
    );

    controller.forward();
    controller.repeat(reverse: true, period: const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    EditorModel editor = Provider.of<EditorModel>(context);

    if (widget.index < editor.file.lines.length) {
      initPainters(editor.file.lines[widget.index].first, editor.localUser.selection);
    }

    localUserLineIndex = editor.localUser.cursorPosition.y;
    usersOnLine = editor.users.where((element) => element.cursorPosition.y == widget.index).toList();

    lineHeight = max(20 + (usersOnLine.isEmpty ? 0 : 20),
        textPainter.computeLineMetrics().length * 20 + (usersOnLine.isEmpty ? 0 : 20));
    //print(lineHeight);

    Color containerColor;

    if (editor.localUser.cursorPosition.y == widget.index) {
      containerColor = Colors.grey.withOpacity(0.2);
    } else {
      containerColor = Colors.transparent;
    }

    Point<int>? background;
    if (!editor.localUser.selection.isEmpty) {
      Selection selection = editor.localUser.selection.readyToWork;
      if (selection.start.y <= widget.index && selection.end.y > widget.index) {
        if (selection.start.y == widget.index) {
          background = Point(selection.start.x, -1);
        } else {
          background = const Point(0, -1);
        }
      } else if (selection.start.y <= widget.index && selection.end.y == widget.index) {
        if (selection.start.y == widget.index) {
          background = Point(selection.start.x, selection.end.x);
        } else {
          background = Point(0, selection.end.x);
        }
      } else {
        background = null;
      }
    }

    return Container(
      color: containerColor,
      width: widget.lineWidth,
      height: lineHeight,
      child: Stack(
        children: [
          CustomPaint(
            painter: LinePainter(indexPainter, textPainter, usersOnLine.isEmpty ? 0 : 20,
                position: editor.localUser.cursorPosition.y == widget.index ? editor.localUser.cursorPosition.x : null,
                animationValue: controller.value,
                background: background),
            foregroundPainter: null,
          ),
          CustomPaint(
            painter: UsersPainter(
              textPainter,
              usersOnLine,
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class LinePainter extends CustomPainter {
  final TextPainter textPainter;
  final TextPainter indexPainter;
  final int? position;
  final Point<int>? background;
  final double? animationValue;
  final double textOffset;
  LinePainter(this.indexPainter, this.textPainter, this.textOffset,
      {this.position, this.animationValue, this.background});

  @override
  void paint(Canvas canvas, Size size) {
    var cursorPaint = Paint();
    cursorPaint.color = Colors.blue.withOpacity(0.5);
    const double fullwidth = 4000;

    indexPainter.paint(canvas, Offset(48 - indexPainter.width, textOffset));

    if (background != null) {
      var cursorOffsetStart = textPainter.getOffsetForCaret(TextPosition(offset: background!.x), Rect.zero);
      if (background!.y == -1) {
        if (textPainter.height == LineWidget.baseHeight) {
          canvas.drawRRect(
              roundRect(
                  Rect.fromLTWH(
                      cursorOffsetStart.dx + 64, cursorOffsetStart.dy + textOffset, fullwidth, LineWidget.baseHeight),
                  [1, 1, 1, 1]),
              cursorPaint);
        } else {
          canvas.drawRRect(
              roundRect(
                  Rect.fromLTWH(
                      cursorOffsetStart.dx + 64, cursorOffsetStart.dy + textOffset, fullwidth, LineWidget.baseHeight),
                  [1, 1, 1, 1]),
              cursorPaint);
          for (double i = cursorOffsetStart.dy + LineWidget.baseHeight;
              i < textPainter.height;
              i += LineWidget.baseHeight) {
            canvas.drawRRect(
                roundRect(Rect.fromLTWH(0 + 64, i + textOffset, fullwidth, LineWidget.baseHeight), [1, 1, 1, 1]),
                cursorPaint);
          }
        }
      } else {
        var cursorOffsetEnd = textPainter.getOffsetForCaret(TextPosition(offset: background!.y), Rect.zero);
        if (cursorOffsetStart.dy == cursorOffsetEnd.dy) {
          canvas.drawRRect(
              roundRect(
                  Rect.fromLTWH(cursorOffsetStart.dx + 64, cursorOffsetStart.dy + textOffset,
                      cursorOffsetEnd.dx - cursorOffsetStart.dx, LineWidget.baseHeight),
                  [1, 1, 1, 1]),
              cursorPaint);
        } else {
          canvas.drawRRect(
              roundRect(
                  Rect.fromLTWH(
                      cursorOffsetStart.dx + 64, cursorOffsetStart.dy + textOffset, fullwidth, LineWidget.baseHeight),
                  [1, 1, 1, 1]),
              cursorPaint);
          for (double i = cursorOffsetStart.dy + LineWidget.baseHeight;
              i < cursorOffsetEnd.dy;
              i += LineWidget.baseHeight) {
            canvas.drawRRect(
                roundRect(Rect.fromLTWH(0 + 64, i + textOffset, fullwidth, LineWidget.baseHeight), [1, 1, 1, 1]),
                cursorPaint);
          }
          canvas.drawRRect(
              roundRect(
                  Rect.fromLTWH(0 + 64, cursorOffsetEnd.dy + textOffset, cursorOffsetEnd.dx, LineWidget.baseHeight),
                  [1, 1, 1, 1]),
              cursorPaint);
        }
      }
    }

    textPainter.paint(canvas, Offset(64, textOffset));

    if (position != null && animationValue != null) {
      cursorPaint.color = Colors.black.withOpacity(animationValue!);
      var cursorOffset = textPainter.getOffsetForCaret(TextPosition(offset: position!), Rect.zero);
      canvas.drawRRect(
          roundRect(Rect.fromLTWH(cursorOffset.dx + 64, cursorOffset.dy + textOffset, 2, 20), [1, 1, 1, 1]),
          cursorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class UsersPainter extends CustomPainter {
  final TextPainter textPainter;
  final List<User> users;

  UsersPainter(this.textPainter, this.users);

  @override
  void paint(Canvas canvas, Size size) {
    for (var user in users) {
      drawCursor(canvas, size, user);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void drawCursor(Canvas canvas, Size size, User user) {
    var cursorPosition = textPainter.getOffsetForCaret(
      TextPosition(offset: user.cursorPosition.x),
      Rect.zero,
    );

    var paint = Paint();
    paint.color = user.color;

    var text = TextPainter(
      text: TextSpan(
        text: user.name,
        style: const TextStyle(
          fontSize: 12,
          height: 1,
          fontFamily: "Roboto",
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    text.layout();

    var background = roundRect(
      Rect.fromLTWH(cursorPosition.dx + 64, 0, text.width + 12, 20.0),
      [6, 0, 6, 6],
    );

    var cursor = roundRect(
      Rect.fromLTWH(cursorPosition.dx + 64, 0 + 10, 2.0, cursorPosition.dy + 30.0),
      [0, 1, 0, 1],
    );

    canvas.drawRRect(background, paint);
    canvas.drawRRect(cursor, paint);

    text.paint(
        canvas,
        Offset(
          cursorPosition.dx + 64 + 6,
          5,
        ));
  }
}
