import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polyscript/ui/editor/line_index_widget.dart';
import 'package:polyscript/ui/styles.dart';

import '../../main.dart';
import '../../model/user.dart';
import '../cursor_painter.dart';

class TextEditor extends StatefulWidget {
  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  TextEditingController editorController = TextEditingController(text: "");
  ScrollController scrollController = ScrollController();
  LineIndexPainter lineIndexPainter = LineIndexPainter();
  
  GlobalKey _textFieldKey = GlobalKey();
  late TextField _textField;
  double xCaret = 0.0;
  double yCaret = 0.0;
  double painterWidth = 0.0;
  double painterHeight = 0.0;
  double preferredLineHeight = 0.0;
  double minWidth = 500.0;
  double maxWidth = 500.0;
  
  @override
  void initState() {

    super.initState();

    scrollController.addListener(() {
      setState(() {
        lineIndexPainter.scrollOffset = scrollController.offset;
      });

    });
      editorController.addListener(() {
      _updateCaretOffset(editorController.text);
    });
  }

  void _updateCaretOffset(String text) {

    if (users.isNotEmpty) {
          users.removeLast();
        }

    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      text: TextSpan(
        style: textStyle,
        text: text,
      ),
    );
    painter.layout(minWidth: 20, maxWidth: maxWidth-64);

    TextPosition cursorTextPosition = editorController.selection.extent;
    Rect caretPrototype = Rect.fromLTWH(
        0.0, 0.0, _textField.cursorWidth, _textField.cursorHeight ?? 0);
    Offset carretPozition =
        painter.getOffsetForCaret(cursorTextPosition, caretPrototype);

    setState(() {
    users.add( User(Point(carretPozition.dx, carretPozition.dy), "StarProximaa", Colors.teal));
      xCaret = carretPozition.dx;
      yCaret = carretPozition.dy;
      painterWidth = painter.width;
      painterHeight = painter.height;
      preferredLineHeight = painter.preferredLineHeight;
    });
  }


  @override
  Widget build(BuildContext context) {

    String text = '''
xCaret: $xCaret
yCaret: $yCaret
yCaretBottom: ${yCaret + preferredLineHeight}
''';

    _textField = TextField(
      // onChanged: (text) {
      //   textPainter.text = TextSpan(text: text, style: textStyle);
      //   textPainter.layout(minWidth: constraints.minWidth - 64, maxWidth: constraints.maxWidth - 64);
      //   setState(() {
      //     lineIndexPainter.linesCount = textPainter.computeLineMetrics().length;
      //   });
      // },
      decoration: null,
      maxLines: null,
      style: textStyle,

      key: _textFieldKey,
      controller: editorController,
      scrollController: scrollController,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        minWidth = constraints.minWidth;
        maxWidth = constraints.maxWidth;
        print(maxWidth);
        return SizedBox(
          width: 100,
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                constraints: const BoxConstraints(minHeight: double.infinity),
                child: CustomPaint(
                  painter: lineIndexPainter,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: double.infinity),
                  child: Stack(children:[
                      _textField,
                      CustomPaint(
                        painter: CursorPainter(users, scrollOffset: scrollController.hasClients ? scrollController.offset : 0))
                    ]
                  )
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
