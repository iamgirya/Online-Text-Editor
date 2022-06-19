import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:polyscript/ui/editor/line_index_widget.dart';
import 'package:polyscript/ui/styles.dart';

class TextEditor extends StatefulWidget {
  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  late TextPainter textPainter;
  TextEditingController editorController = TextEditingController(text: "");
  ScrollController scrollController = ScrollController();
  LineIndexPainter lineIndexPainter = LineIndexPainter();
  @override
  void initState() {
    textPainter = TextPainter(
        text: const TextSpan(text: "", style: textStyle), textDirection: TextDirection.ltr, textAlign: TextAlign.left);

    super.initState();

    scrollController.addListener(() {
      setState(() {
        lineIndexPainter.scrollOffset = scrollController.offset;
      });

      editorController.addListener(test);
    });
  }

  void test() {
    log("hiii");
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        textPainter.layout(minWidth: constraints.minWidth - 64, maxWidth: constraints.maxWidth - 64.0);

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
                  child: TextField(
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
                    controller: editorController,
                    scrollController: scrollController,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
