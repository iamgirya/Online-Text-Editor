import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/ui/editor/line/painters/cursor_painter.dart';
import 'package:polyscript/ui/styles.dart';
import 'package:provider/provider.dart';
import '../../../model/user_model.dart';
import 'painters/line_painter.dart';
import 'painters/selection_painter.dart';

class LineWidget extends StatefulWidget {
  static const double baseHeight = 20;
  static const double lineIndexingWidth = 48;
  static const double spaceBetweenIndexAndText = 16;

  static double get leftTextOffset {
    return LineWidget.lineIndexingWidth + LineWidget.spaceBetweenIndexAndText;
  }

  final int index;
  final String text;
  final double lineWidth;

  const LineWidget({
    Key? key,
    required this.text,
    required this.index,
    required this.lineWidth,
  }) : super(key: key);

  @override
  State<LineWidget> createState() => LineWidgetState();
}

class LineWidgetState extends State<LineWidget> with TickerProviderStateMixin {
  late TextPainter indexPainter;
  late TextPainter textPainter;
  late double lineHeight;
  var localUserLineIndex = -1;

  //TODO: перенести анимацию из каждой линии в виджет редактора
  //TODO: ну или сделать анимацию только при нахождении локального пользователя на линии
  late Animation<double> animation;
  late AnimationController controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
  late List<User> usersOnLine;

  bool get isExistUnlocalUsersOnLine {
    return usersOnLine.length > 1 || (usersOnLine.length == 1 && !usersOnLine[0].isLocal);
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      if (localUserLineIndex == widget.index) {
        setState(() {});
      }
    });

    animation = CurvedAnimation(parent: controller, curve: Curves.linear, reverseCurve: Curves.easeIn);

    controller.forward();
    controller.repeat(reverse: true, period: const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    EditorModel editor = Provider.of<EditorModel>(context);

    if (widget.index < editor.file.lines.length) {
      initPainters(editor.file.lines[widget.index].first);
    }

    localUserLineIndex = editor.localUser.cursorPosition.y;

    usersOnLine = editor.users.where((user) => user.cursorPosition.y == widget.index).toList();

    lineHeight = max(20 + (isExistUnlocalUsersOnLine ? 20 : 0),
        textPainter.computeLineMetrics().length * 20 + (isExistUnlocalUsersOnLine ? 20 : 0));

    Color containerColor;

    if (editor.localUser.cursorPosition.y == widget.index) {
      containerColor = Colors.grey.withOpacity(0.2);
    } else {
      containerColor = Colors.transparent;
    }

    return Container(
      color: containerColor,
      width: widget.lineWidth,
      height: lineHeight,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(widget.lineWidth, lineHeight),
            painter: SelectionPainter(
              textPainter,
              editor.users,
              widget.index,
            ),
          ),
          CustomPaint(
            size: Size(widget.lineWidth, lineHeight),
            painter: LinePainter(
              indexPainter,
              textPainter,
              isExistUnlocalUsersOnLine ? 20 : 0,
            ),
          ),
          CustomPaint(
            size: Size(widget.lineWidth, lineHeight),
            painter: CursorPainter(
              textPainter,
              usersOnLine,
              isExistUnlocalUsersOnLine ? 20 : 0,
              animationValue: controller.value,
            ),
          )
        ],
      ),
    );
  }

  void initPainters(String text) {
    indexPainter = TextPainter(
      text: TextSpan(
        text: widget.index.toString(),
        style: indexStyle,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    indexPainter.layout(minWidth: LineWidget.lineIndexingWidth, maxWidth: LineWidget.lineIndexingWidth);

    textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    textPainter.layout(
        minWidth: widget.lineWidth - LineWidget.lineIndexingWidth,
        maxWidth: widget.lineWidth - LineWidget.lineIndexingWidth);
  }

  int getCursorOffset(Offset position) {
    var yOffset = isExistUnlocalUsersOnLine ? 20 : 0;
    return textPainter.getPositionForOffset(Offset(position.dx, position.dy - yOffset)).offset;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
