import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/ui/editor/line_widget.dart';
import 'package:provider/provider.dart';

import 'editor_inherit.dart';

class TextEditorWidget extends StatefulWidget {
  const TextEditorWidget({Key? key}) : super(key: key);

  @override
  State<TextEditorWidget> createState() => _TextEditorWidgetState();
}

class _TextEditorWidgetState extends State<TextEditorWidget> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {});
  }

  //поиск позиции курсора, который нходится на координатах position
  Point<int>? getCursorPosition(Offset position, Element element) {
    Point<int>? result;

    element.visitChildren((child) {
      if (child.widget is LineWidget && result == null) {
        var transform = child.renderObject!.getTransformTo(null).getTranslation();
        var frame = Rect.fromLTWH(
          transform.x,
          transform.y,
          child.renderObject!.paintBounds.width,
          child.renderObject!.paintBounds.height,
        );

        if (frame.contains(position) && result == null) {
          var line = child.widget as LineWidget;
          var state = (child as StatefulElement).state as LineWidgetState;

          var localPosition = Offset(
            position.dx - frame.left - 64,
            position.dy - frame.top,
          );

          print(localPosition);

          result = Point<int>(
            state.getCursorOffset(localPosition),
            line.index,
          );
        }
      } else {
        result ??= getCursorPosition(position, child);
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    EditorModel editor = EditorInherit.of(context).editor;

    return LayoutBuilder(
      builder: ((context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            print("press in " + details.globalPosition.toString());
            context.visitChildElements((element) {
              var newPosition = getCursorPosition(details.globalPosition, element);
              print(newPosition.toString());

              if (newPosition != null) {
                editor.updateLocalUser(newPosition: newPosition);
              }
            });
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            itemCount: editor.file.lines.length,
            itemBuilder: ((context, index) {
              return ChangeNotifierProvider.value(
                value: editor,
                child: LineWidget(
                  text: editor.file.lines[index],
                  index: index,
                  lineWidth: constraints.maxWidth,
                ),
              );
            }),
            controller: scrollController,
          ),
        );
      }),
    );
  }
}
