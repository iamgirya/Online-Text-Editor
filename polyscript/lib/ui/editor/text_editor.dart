import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polyscript/ui/editor/line_index_widget.dart';
import 'package:polyscript/ui/styles.dart';

import '../../model/user.dart';
import '../cursor_painter.dart';

class TextEditor extends StatefulWidget {
  const TextEditor({Key? key}) : super(key: key);

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  TextEditingController editorController = TextEditingController(text: "");
  ScrollController scrollController = ScrollController();
  LineIndexPainter lineIndexPainter = LineIndexPainter();
  late TextPainter textPainter;
  late TextField _textField;
  List<User> users = [];

  // GlobalKey _textFieldKey = GlobalKey();
  // double xCaret = 0.0;
  // double yCaret = 0.0;
  // double painterWidth = 0.0;
  // double painterHeight = 0.0;
  // double preferredLineHeight = 0.0;
  double maxWidth = 500.0;
  double savedWidth = 0;

  @override
  void initState() {

    super.initState();

    textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      maxLines: null,
      text: const TextSpan(
        style: textStyle,
        text: "",
      ),
    );

    scrollController.addListener(() {
      setState(() {
        lineIndexPainter.scrollOffset = scrollController.offset;
      });

    });
      editorController.addListener(() {
      _updateCaretOffset(editorController.text, true);
    });
  }

  
  void _updateCaretOffset(String text, bool needToRebuild) {

     textPainter.text = TextSpan(
        style: textStyle,
        text: text,
      );

    if (savedWidth == 0) {
      textPainter.layout(minWidth: 20.0, maxWidth: maxWidth-64.0);
    } else {
      textPainter.layout(minWidth: 20.0, maxWidth: savedWidth);
    }
    if (savedWidth == 0 && maxWidth-64.0 - textPainter.width < 3) {
      savedWidth = maxWidth-67.0;
      textPainter.layout(minWidth: 20.0, maxWidth: savedWidth );
    }
    
    TextPosition cursorTextPosition = editorController.selection.extent;
    Rect caretPrototype = Rect.fromLTWH(
        0.0, 0.0, _textField.cursorWidth, _textField.cursorHeight ?? 0);
    Offset carretPozition =
        textPainter.getOffsetForCaret(cursorTextPosition, caretPrototype);

    if (needToRebuild){
    setState(() {
      setMyCarret(carretPozition);
      // xCaret = carretPozition.dx;
      // print("xc" +carretPozition.dx.toString());
      // yCaret = carretPozition.dy;
      // painterWidth = textPainter.width;
      // print("pw" +painterWidth.toString());
      // painterHeight = textPainter.height;
      // preferredLineHeight = textPainter.preferredLineHeight;
    });

    }
    else {
      setMyCarret(carretPozition);
    }
  }

  void setMyCarret(Offset carretPozition)
  {
    if (users.isNotEmpty) {
      users.removeLast();
    }
    users.add( User(Point(carretPozition.dx, carretPozition.dy), "MyName", Colors.teal));
  }

  @override
  Widget build(BuildContext context) {

    _textField = TextField(
      decoration: null,
      maxLines: null,
      style: textStyle,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,

      controller: editorController,
      scrollController: scrollController,
    );

    return LayoutBuilder(
      builder: (context, constraints) {

        if (savedWidth != 0 && constraints.maxWidth != maxWidth) {
          savedWidth -= maxWidth-constraints.maxWidth;
          maxWidth = constraints.maxWidth;

          _updateCaretOffset(editorController.text, false);
        }
        else if (maxWidth != constraints.maxWidth) {
          maxWidth = constraints.maxWidth;
          _updateCaretOffset(editorController.text, false);
        }
        print(maxWidth-64);
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
