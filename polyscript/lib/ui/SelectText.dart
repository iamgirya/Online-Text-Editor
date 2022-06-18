import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:polyscript/ui/styles.dart';

import '../main.dart';
import '../model/user.dart';

String startText =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

class SelectText extends StatefulWidget {
  const SelectText({ Key? key , required this.onClick }) : super(key: key);

  final Function onClick;
  @override
  State<SelectText> createState() => _SelectTextState();
}
class _SelectTextState extends State<SelectText> {

    final fieldController = TextEditingController();
  final scrollController = ScrollController(initialScrollOffset: 0);

  var textPainter = TextPainter(
        text: TextSpan(text: startText, style: textStyle),
        textDirection: TextDirection.ltr,
      );

void kak(){
  setState(() {
    fieldController.selection.base;
    if (users.isNotEmpty) {
          users.removeLast();
        }

    Offset carretPozition = textPainter.getOffsetForCaret(fieldController.selection.base, Rect.zero);

    users.add( User(Point(carretPozition.dx, carretPozition.dy), "StarProximaa", Colors.teal));

    print(carretPozition);
    });
  }

@override
  void initState() {
    fieldController.addListener(kak);
    super.initState();
  }

    @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {

      final width = constraints.maxWidth;
      textPainter.layout(
        minWidth: 20,
        maxWidth: width,
      );
      final height = textPainter.height;

      return TextField(
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