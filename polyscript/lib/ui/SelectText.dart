import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:polyscript/ui/styles.dart';

import '../main.dart';
import '../model/user.dart';

String startText ="hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh";

class SelectText extends StatefulWidget {
  const SelectText({ Key? key , required this.onClick }) : super(key: key);

  final Function onClick;
  @override
  State<SelectText> createState() => _SelectTextState();
}
class _SelectTextState extends State<SelectText> {

    final fieldController = TextEditingController();
  final scrollController = ScrollController(initialScrollOffset: 0);

  late TextPainter textPainter;

void kak() {
  setState(() {
    if (users.isNotEmpty) {
          users.removeLast();
        }
      Offset carretPozition;
      TextPosition selectTextPosition = fieldController.selection.extent;
      if (selectTextPosition.offset > (textPainter.text as TextSpan).text!.length) {
        var newPosition = TextPosition(offset: (textPainter.text as TextSpan).text!.length, affinity: selectTextPosition.affinity);
        carretPozition = textPainter.getOffsetForCaret(newPosition, Rect.zero);
      }
      else if (fieldController.text.length != 0 && fieldController.text.codeUnits.last == 10) {
        print(fieldController.text[fieldController.text.length-1]);
        carretPozition = textPainter.getOffsetForCaret(fieldController.selection.extent, Rect.zero);
      }
      else {
        carretPozition = textPainter.getOffsetForCaret(fieldController.selection.extent, Rect.zero);

      }
      users.add( User(Point(carretPozition.dx, carretPozition.dy), "StarProximaa", Colors.teal));
    });
  }

@override
  void initState() {
    fieldController.addListener(kak);
    super.initState();
  }

    @override
  Widget build(BuildContext context) {
    
    textPainter = TextPainter(
        text: TextSpan(text: fieldController.text, style: textStyle),
        textDirection: TextDirection.ltr,
      );
    
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {

      final width = constraints.maxWidth;
      textPainter.layout(
        minWidth: 0,
        maxWidth: width,
      );
      final height = textPainter.height;

      return Stack(
        children: [
          CustomPaint(
              size: Size(width, height), // Parent width, text height
              painter: TextCustomPainter(textPainter),
            ),
          TextField(
            selectionHeightStyle: BoxHeightStyle.includeLineSpacingMiddle,
            maxLines: null,
            decoration: const InputDecoration(contentPadding: EdgeInsets.all(0), isCollapsed: true),
            controller: fieldController,
            scrollController: scrollController,
            style: const TextStyle(
              fontFamily: "Roboto",
              fontStyle: FontStyle.normal,
              fontSize: 16,
              height: 1.25,
            ),
          ),
          
          ]
      );
      }
    );
  }
}

class TextCustomPainter extends CustomPainter {
  TextPainter textPainter;

  TextCustomPainter(this.textPainter, {Listenable? repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.paint(canvas, Offset(0, 0));
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}