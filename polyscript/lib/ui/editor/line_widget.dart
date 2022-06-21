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

  void initPainters(String text) {
    indexPainter = TextPainter(
      text: TextSpan(
        text: widget.index.toString(),
        style: indexStyle,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    indexPainter.layout(minWidth: 48, maxWidth: 48);

    textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

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
    initPainters(editor.file.lines[widget.index]);

    localUserLineIndex = editor.localUser.cursorPosition.y;
    usersOnLine = editor.users.where((element) => element.cursorPosition.y == widget.index).toList();

    lineHeight = textPainter.computeLineMetrics().length * 20 + (usersOnLine.isEmpty ? 0 : 20);

    return Container(
      color: editor.localUser.cursorPosition.y == widget.index ? Colors.grey.withOpacity(0.2) : Colors.transparent,
      width: widget.lineWidth,
      height: lineHeight,
      child: Stack(
        children: [
          CustomPaint(
            painter: LinePainter(indexPainter, textPainter, usersOnLine.isEmpty ? 0 : 20,
                position: editor.localUser.cursorPosition.y == widget.index ? editor.localUser.cursorPosition.x : null,
                animationValue: controller.value),
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
  final double? animationValue;
  final double textOffset;
  LinePainter(this.indexPainter, this.textPainter, this.textOffset, {this.position, this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    indexPainter.paint(canvas, Offset(48 - indexPainter.width, textOffset));
    textPainter.paint(canvas, Offset(64, textOffset));

    if (position != null) {
      var cursorPaint = Paint();
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
