import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late EditorModel editor;
  late var preffereCursorPositionX = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {});
  }

  void keyboardNavigation(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (editor.localUser.cursorPosition.x == editor.file.lines[editor.localUser.cursorPosition.y].length) {
          if (editor.localUser.cursorPosition.y < editor.file.lines.length - 1) {
            editor.updateLocalUser(
              newPosition: Point(
                0,
                editor.localUser.cursorPosition.y + 1,
              ),
            );
            preffereCursorPositionX = editor.localUser.cursorPosition.x;
          }
        } else {
          editor.updateLocalUser(
            newPosition: Point(editor.localUser.cursorPosition.x + 1, editor.localUser.cursorPosition.y),
          );
          preffereCursorPositionX = editor.localUser.cursorPosition.x;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (editor.localUser.cursorPosition.x == 0) {
          if (editor.localUser.cursorPosition.y > 0) {
            editor.updateLocalUser(
              newPosition: Point(
                editor.file.lines[editor.localUser.cursorPosition.y - 1].length,
                editor.localUser.cursorPosition.y - 1,
              ),
            );
            preffereCursorPositionX = editor.localUser.cursorPosition.x;
          }
        } else {
          editor.updateLocalUser(
            newPosition: Point(editor.localUser.cursorPosition.x - 1, editor.localUser.cursorPosition.y),
          );
          preffereCursorPositionX = editor.localUser.cursorPosition.x;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (editor.localUser.cursorPosition.y > 0) {
          var xPosition = min(preffereCursorPositionX, editor.file.lines[editor.localUser.cursorPosition.y - 1].length);
          editor.updateLocalUser(
            newPosition: Point(
              xPosition,
              editor.localUser.cursorPosition.y - 1,
            ),
          );
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (editor.localUser.cursorPosition.y < editor.file.lines.length - 1) {
          var xPosition = min(preffereCursorPositionX, editor.file.lines[editor.localUser.cursorPosition.y + 1].length);
          editor.updateLocalUser(
            newPosition: Point(
              xPosition,
              editor.localUser.cursorPosition.y + 1,
            ),
          );
        }
      }
    }
  }

  //поиск позиции курсора, который нaходится на координатах position
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
    editor = EditorInherit.of(context).editor;

    return LayoutBuilder(
      builder: ((context, constraints) {
        return GestureDetector(
          onTapDown: (details) {
            context.visitChildElements((element) {
              var newPosition = getCursorPosition(details.globalPosition, element);
              if (newPosition != null) {
                editor.updateLocalUser(newPosition: newPosition);
                preffereCursorPositionX = newPosition.x;
              }
            });
          },
          child: KeyboardListener(
            autofocus: true,
            focusNode: FocusNode(),
            onKeyEvent: (keyEvent) {
              if (keyEvent is! KeyUpEvent && keyEvent.character != null) {
                String newLine = editor.file.lines[editor.localUser.cursorPosition.y]
                        .substring(0, editor.localUser.cursorPosition.x) +
                    keyEvent.character! +
                    editor.file.lines[editor.localUser.cursorPosition.y].substring(editor.localUser.cursorPosition.x);

                editor.updateFileModel(lineIndex: editor.localUser.cursorPosition.y, newText: newLine, inputLength: 1);
              } else if (keyEvent is KeyDownEvent) {
                keyboardNavigation(keyEvent);
              }
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
          ),
        );
      }),
    );
  }
}
