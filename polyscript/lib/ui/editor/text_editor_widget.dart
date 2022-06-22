import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/model/user_model.dart';
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
  late var textEditorFocus = FocusNode();
  var editorHeight = 0.0;
  late var preffereCursorPositionX = 0;
  List<GlobalKey<LineWidgetState>> linesList = [];

  Point<int>? highlightStart;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {});
  }

  void keyboardNavigation(KeyEvent event) {
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
      }
      preffereCursorPositionX = editor.localUser.cursorPosition.x;
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
      
      // LineWidget, на котором находится курсор
      Element element = linesList[editor.localUser.cursorPosition.y].currentContext as Element;
      Point<int>? newPosition;
      Offset? cursorPosition = getCursorPositionInScreen(
        Offset(
          editor.localUser.cursorPosition.x.toDouble(),
          editor.localUser.cursorPosition.y.toDouble(),
        ),
        element,
      );
      double yOffset = linesList[editor.localUser.cursorPosition.y].currentState!.usersOnLine.isEmpty ? 0 : 20;

      if (cursorPosition != null) {  
        // делаем сдвиг по координатам
        cursorPosition = Offset(cursorPosition.dx, cursorPosition.dy
          -LineWidget.baseHeight+yOffset);
        // вычисляем новое положение
        newPosition = getCursorPositionInText(cursorPosition, element);
        // если оно null, значит, курсор переходит на следующий LineWidget
        if (newPosition == null && editor.localUser.cursorPosition.y > 0) {
          element = linesList[editor.localUser.cursorPosition.y-1].currentContext as Element;
          newPosition = getCursorPositionInText(cursorPosition, element);
        }
        
        if (newPosition != null) {
          if (newPosition != editor.localUser.cursorPosition) {
            editor.updateLocalUser(newPosition: newPosition);
            preffereCursorPositionX = newPosition.x;
          }
          // Случай, когда при сдвиге положение курсора не изменилось возможно лишь при случае, когда с линии, на которой есть другой пользователь идёт попытака перейти на другую линию. В этом случае, наборот, не учитываем сдвиг по y
          else if (editor.localUser.cursorPosition.y > 0) {
            cursorPosition = Offset(cursorPosition.dx, cursorPosition.dy
              -LineWidget.baseHeight);
            element = linesList[editor.localUser.cursorPosition.y-1].currentContext as Element;
            newPosition = getCursorPositionInText(cursorPosition, element);
            if (newPosition != null) {
              editor.updateLocalUser(newPosition: newPosition);
              preffereCursorPositionX = newPosition.x;
            }
          }

          scrollList(element);
        }
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // LineWidget, на котором находится курсор
      Element element = linesList[editor.localUser.cursorPosition.y].currentContext as Element;
      Point<int>? newPosition;
      Offset? cursorPosition = getCursorPositionInScreen(
        Offset(
          editor.localUser.cursorPosition.x.toDouble(),
          editor.localUser.cursorPosition.y.toDouble(),
        ),
        element,
      );
      double yOffset = linesList[editor.localUser.cursorPosition.y].currentState!.usersOnLine.isEmpty ? 0 : 20;

      if (cursorPosition != null) {  
        // делаем сдвиг по координатам
        cursorPosition = Offset(cursorPosition.dx, cursorPosition.dy
          +LineWidget.baseHeight+yOffset);
        // вычисляем новое положение
        newPosition = getCursorPositionInText(cursorPosition, element);
        // если оно null, значит, курсор переходит на следующий LineWidget
        if (newPosition == null && editor.localUser.cursorPosition.y +1 < editor.file.lines.length) {
          element = linesList[editor.localUser.cursorPosition.y+1].currentContext as Element;
          newPosition = getCursorPositionInText(cursorPosition, element);
        }
        
        if (newPosition != null) {
          if (newPosition != editor.localUser.cursorPosition) {
            editor.updateLocalUser(newPosition: newPosition);
            preffereCursorPositionX = newPosition.x;
          }
          // Случай, когда при сдвиге положение курсора не изменилось возможно лишь при случае, когда с линии, на которой есть другой пользователь идёт попытака перейти на другую линию. В этом случае, наборот, не учитываем сдвиг по y
          else if (editor.localUser.cursorPosition.y +1 < editor.file.lines.length) {
            cursorPosition = Offset(cursorPosition.dx, cursorPosition.dy
              +LineWidget.baseHeight);
            element = linesList[editor.localUser.cursorPosition.y+1].currentContext as Element;
            newPosition = getCursorPositionInText(cursorPosition, element);
            if (newPosition != null) {
              editor.updateLocalUser(newPosition: newPosition);
              preffereCursorPositionX = newPosition.x;
            }
          }

          scrollList(element);
        }
      }
    }
  }

  void scrollList(Element element) {
    var cursorPosition = getCursorPositionInScreen(
      Offset(
        editor.localUser.cursorPosition.x.toDouble(),
        editor.localUser.cursorPosition.y.toDouble(),
      ),
      element,
    );
    if (cursorPosition != null && cursorPosition.dy > editorHeight) {
      scrollController.animateTo(scrollController.offset + (cursorPosition.dy - editorHeight + 20 + 16),
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }
    if (cursorPosition != null && cursorPosition.dy < 0) {
      scrollController.animateTo(scrollController.offset + cursorPosition.dy - 20,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }
  }

  //поиск позиции курсора в тексте, который нaходится на координатах position
  Point<int>? getCursorPositionInText(Offset position, Element element) {
    Point<int>? result;

    if (element.widget is LineWidget && result == null) {
        var transform = element.renderObject!.getTransformTo(null).getTranslation();
        var frame = Rect.fromLTWH(
          transform.x,
          transform.y,
          element.renderObject!.paintBounds.width,
          element.renderObject!.paintBounds.height,
        );

        if (frame.contains(position) && result == null) {
          var line = element.widget as LineWidget;
          var state = (element as StatefulElement).state as LineWidgetState;

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
        element.visitChildren((child) {
            result ??= getCursorPositionInText(position, child);
        });
      }
    return result;
  }

  //поиск позиции курсора на экране, который нaходится на координатах position
  Offset? getCursorPositionInScreen(Offset position, Element element) {
    Offset? result;
    
    if (element.widget is LineWidget &&
          result == null &&
          (element.widget as LineWidget).index == editor.localUser.cursorPosition.y) {
        var transform = element.renderObject!.getTransformTo(null).getTranslation();
        var frame = Rect.fromLTWH(
          transform.x,
          transform.y,
          element.renderObject!.paintBounds.width,
          element.renderObject!.paintBounds.height,
        );

        var state = (element as StatefulElement).state as LineWidgetState;
        var lineOffset =
            state.textPainter.getOffsetForCaret(TextPosition(offset: editor.localUser.cursorPosition.x), Rect.zero);

        result = Offset(
          transform.x + lineOffset.dx + 64,
          transform.y + lineOffset.dy,
        );
      } else {
        element.visitChildren((child) {
          result ??= getCursorPositionInScreen(position, child);
        });
      }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    editor = EditorInherit.of(context).editor;

    //editor.users.add(User(Point(4,0), "00", Color.fromARGB(255, 255, 0, 0)));
    return LayoutBuilder(
      builder: ((context, constraints) {
        editorHeight = constraints.maxHeight;
        return GestureDetector(
          onDoubleTapDown: (details) {},
          onTapDown: (details) {
            textEditorFocus.requestFocus();
            context.visitChildElements((element) {
              var newPosition = getCursorPositionInText(details.globalPosition, element);
              if (newPosition != null) {
                editor.updateLocalUser(newPosition: newPosition, newSelection: Selection.none());
                preffereCursorPositionX = newPosition.x;
              }
            });
          },
          onHorizontalDragStart: (details) {
            editor.updateLocalUser(newSelection: Selection.none());
            textEditorFocus.requestFocus();
            highlightStart = getCursorPositionInText(details.globalPosition, context as Element);
          },
          onHorizontalDragUpdate: (details) {
            // отображение выделения
            var newPosition = getCursorPositionInText(details.globalPosition, context as Element);
            if (highlightStart != null && newPosition != null) {
              editor.updateLocalUser(newPosition: newPosition, newSelection: Selection(highlightStart!, newPosition));
              preffereCursorPositionX = newPosition.x;
            
              //скролл
              scrollList(linesList[editor.localUser.cursorPosition.y].currentContext as Element);
            }
          },
          onHorizontalDragEnd: (details) {
            highlightStart = null;
          },
          child: KeyboardListener(
            autofocus: true,
            focusNode: textEditorFocus,
            onKeyEvent: (keyEvent) {
              if (keyEvent is! KeyUpEvent && keyEvent.character != null) {
                String newLine = "";
                if (keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
                  newLine = editor.file.lines[editor.localUser.cursorPosition.y]
                          .substring(0, editor.localUser.cursorPosition.x - 1) +
                      editor.file.lines[editor.localUser.cursorPosition.y].substring(editor.localUser.cursorPosition.x);
                  editor.updateFileModel(
                      lineIndex: editor.localUser.cursorPosition.y, newText: newLine, inputLength: -1);
                } else {
                  newLine = editor.file.lines[editor.localUser.cursorPosition.y]
                          .substring(0, editor.localUser.cursorPosition.x) +
                      keyEvent.character! +
                      editor.file.lines[editor.localUser.cursorPosition.y].substring(editor.localUser.cursorPosition.x);
                  editor.updateFileModel(
                      lineIndex: editor.localUser.cursorPosition.y, newText: newLine, inputLength: 1);
                }
              } else if (keyEvent is! KeyUpEvent) {
                keyboardNavigation(keyEvent);
              } else {}
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              itemCount: editor.file.lines.length,
              itemBuilder: ((context, index) {
                if (linesList.length > index) {
                  linesList[index] = GlobalKey<LineWidgetState>();
                }
                else {
                  linesList.add(GlobalKey<LineWidgetState>());
                }
                return ChangeNotifierProvider.value(
                  value: editor,
                  child: LineWidget(
                    key: linesList[index],
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
