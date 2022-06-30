import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polyscript/model/actions/insert_text_action.dart';
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

  late DateTime lastTapTime;

  Point<int>? highlightStart;

  @override
  void initState() {
    super.initState();
    lastTapTime = DateTime.now();
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
        cursorPosition = Offset(cursorPosition.dx, cursorPosition.dy - LineWidget.baseHeight + yOffset);
        // вычисляем новое положение
        newPosition = getCursorPositionInText(cursorPosition, element);
        // если оно null, значит, курсор переходит на следующий LineWidget
        if (newPosition == null && editor.localUser.cursorPosition.y > 0) {
          element = linesList[editor.localUser.cursorPosition.y - 1].currentContext as Element;
          newPosition = getCursorPositionInText(cursorPosition, element);
        }

        if (newPosition != null) {
          if (newPosition != editor.localUser.cursorPosition) {
            editor.updateLocalUser(newPosition: newPosition);
            preffereCursorPositionX = newPosition.x;
          }
          // Случай, когда при сдвиге положение курсора не изменилось возможно лишь при случае, когда с линии, на которой есть другой пользователь идёт попытака перейти на другую линию. В этом случае, наборот, не учитываем сдвиг по y
          else if (editor.localUser.cursorPosition.y > 0) {
            cursorPosition = Offset(cursorPosition.dx, cursorPosition.dy - LineWidget.baseHeight);
            element = linesList[editor.localUser.cursorPosition.y - 1].currentContext as Element;
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
        cursorPosition = Offset(cursorPosition.dx, cursorPosition.dy + LineWidget.baseHeight + yOffset);
        // вычисляем новое положение
        newPosition = getCursorPositionInText(cursorPosition, element);
        // если оно null, значит, курсор переходит на следующий LineWidget
        if (newPosition == null && editor.localUser.cursorPosition.y + 1 < editor.file.lines.length) {
          element = linesList[editor.localUser.cursorPosition.y + 1].currentContext as Element;
          newPosition = getCursorPositionInText(cursorPosition, element);
        }

        if (newPosition != null) {
          if (newPosition != editor.localUser.cursorPosition) {
            editor.updateLocalUser(newPosition: newPosition);
            preffereCursorPositionX = newPosition.x;
          }
          // Случай, когда при сдвиге положение курсора не изменилось возможно лишь при случае, когда с линии, на которой есть другой пользователь идёт попытака перейти на другую линию. В этом случае, наборот, не учитываем сдвиг по y
          else if (editor.localUser.cursorPosition.y + 1 < editor.file.lines.length) {
            cursorPosition = Offset(cursorPosition.dx, cursorPosition.dy + LineWidget.baseHeight);
            element = linesList[editor.localUser.cursorPosition.y + 1].currentContext as Element;
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

// если курсор находится выше или ниже, то делать скролл до его местонахождения
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

  void makeNewLine({required int previousLineIndex, required String startText}) {
    linesList.insert(previousLineIndex + 1, GlobalKey<LineWidgetState>());

    setState(() {
      editor.makeNewLine(previousLineIndex, startText);
    });
  }

  void deleteLine({required int lineIndex}) {
    linesList.removeAt(lineIndex);

    setState(() {
      editor.deleteLine(lineIndex);
    });
  }

  void deleteLines({required int startLineIndex, required int endLineIndex}) {
    linesList.removeRange(startLineIndex, endLineIndex);

    setState(() {
      editor.deleteLines(startLineIndex, endLineIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    editor = EditorInherit.of(context).editor;

    return ChangeNotifierProvider.value(
        value: editor,
        child: LayoutBuilder(
          builder: ((context, constraints) {
            editorHeight = constraints.maxHeight;
            return GestureDetector(
              onTapDown: (details) {
                textEditorFocus.requestFocus();
                context.visitChildElements((element) {
                  var newPosition = getCursorPositionInText(details.globalPosition, element);
                  if (newPosition != null) {
                    // двойной клик и выделение слова
                    if (newPosition == editor.localUser.cursorPosition &&
                        DateTime.now().difference(lastTapTime).inMilliseconds < 400) {
                      int startOfWord =
                          editor.file.lines[newPosition.y].substring(0, newPosition.x).lastIndexOf(' ') + 1;
                      int endOfWord = editor.file.lines[newPosition.y].substring(newPosition.x).indexOf(' ');
                      if (endOfWord == -1) {
                        endOfWord = editor.file.lines[newPosition.y].length;
                      } else {
                        endOfWord += newPosition.x;
                      }
                      editor.updateLocalUser(
                          newPosition: Point(endOfWord, newPosition.y),
                          newSelection: Selection(Point(startOfWord, newPosition.y), Point(endOfWord, newPosition.y)));
                      preffereCursorPositionX = endOfWord;
                    } else {
                      // обычный клик
                      editor.updateLocalUser(newPosition: newPosition, newSelection: null);
                      preffereCursorPositionX = newPosition.x;
                    }
                    lastTapTime = DateTime.now();
                  }
                });
              },
              // начало выделение
              onHorizontalDragStart: (details) {
                editor.updateLocalUser(newSelection: null);
                textEditorFocus.requestFocus();
                highlightStart = getCursorPositionInText(details.globalPosition, context as Element);
              },
              // начало выделение
              onVerticalDragStart: (details) {
                editor.updateLocalUser(newSelection: null);
                textEditorFocus.requestFocus();
                highlightStart = getCursorPositionInText(details.globalPosition, context as Element);
              },
              // отображение выделения
              onHorizontalDragUpdate: (details) {
                var newPosition = getCursorPositionInText(details.globalPosition, context as Element);
                if (highlightStart != null && newPosition != null) {
                  editor.updateLocalUser(
                      newPosition: newPosition, newSelection: Selection(highlightStart!, newPosition));
                  preffereCursorPositionX = newPosition.x;
                  //скролл
                  scrollList(linesList[editor.localUser.cursorPosition.y].currentContext as Element);
                }
              },
              // отображение выделения
              onVerticalDragUpdate: (details) {
                var newPosition = getCursorPositionInText(details.globalPosition, context as Element);
                if (highlightStart != null && newPosition != null) {
                  editor.updateLocalUser(
                      newPosition: newPosition, newSelection: Selection(highlightStart!, newPosition));
                  preffereCursorPositionX = newPosition.x;
                  //скролл
                  scrollList(linesList[editor.localUser.cursorPosition.y].currentContext as Element);
                }
              },
              // конец выделения
              onHorizontalDragEnd: (details) {
                highlightStart = null;
              },
              // конец выделения
              onVerticalDragEnd: (details) {
                highlightStart = null;
              },
              child: KeyboardListener(
                autofocus: true,
                focusNode: textEditorFocus,
                onKeyEvent: (keyEvent) {
                  String newLine = "";
                  String secondLine = "";
                  if (keyEvent is! KeyUpEvent) {
                    // ввод символа
                    if (keyEvent.character != null &&
                        keyEvent.logicalKey != LogicalKeyboardKey.enter &&
                        keyEvent.logicalKey != LogicalKeyboardKey.backspace) {
                      if (editor.localUser.selection == null) {
                        var action = InsertTextAction(
                            editor.localUserName, keyEvent.character!, editor.localUser.cursorPosition);
                        editor.sendJSON(action.toJson());
                      } else {
                        Selection select = editor.localUser.selection!.readyToWork;

                        //удаление конца первой строки
                        newLine = editor.file.lines[select.start.y].substring(0, select.start.x) + keyEvent.character!;
                        int oldLineLength = select.start.x + 1;
                        // в случае, если выделение лишь на одной строке
                        if (select.end.y == select.start.y) {
                          newLine += editor.file.lines[select.start.y].substring(select.end.x);
                          editor.updateFileModel(
                              lineIndex: editor.localUser.cursorPosition.y, newText: newLine, inputLength: -1);
                          editor.updateLocalUser(newPosition: Point(oldLineLength, select.start.y), newSelection: null);
                          // выделение на нескольких строках
                        } else {
                          newLine += editor.file.lines[select.end.y].substring(select.end.x);
                          // удаление строк
                          deleteLines(startLineIndex: select.start.y + 1, endLineIndex: select.end.y + 1);
                          editor.updateFileModel(lineIndex: select.start.y, newText: newLine, inputLength: -1);
                          editor.updateLocalUser(newPosition: Point(oldLineLength, select.start.y), newSelection: null);
                        }
                      }
                      // стирание
                    } else if (keyEvent.logicalKey == LogicalKeyboardKey.backspace) {
                      // удаление символа
                      if (editor.localUser.selection == null) {
                        // удаление символа переноса строки
                        if (editor.localUser.cursorPosition.y != 0 && editor.localUser.cursorPosition.x == 0) {
                          int previousLineLength = editor.file.lines[editor.localUser.cursorPosition.y - 1].length;
                          newLine = editor.file.lines[editor.localUser.cursorPosition.y - 1] +
                              editor.file.lines[editor.localUser.cursorPosition.y];
                          deleteLine(lineIndex: editor.localUser.cursorPosition.y);
                          editor.updateFileModel(
                              lineIndex: editor.localUser.cursorPosition.y - 1, newText: newLine, inputLength: -1);
                          editor.updateLocalUser(
                              newPosition: Point(previousLineLength, editor.localUser.cursorPosition.y - 1));
                          // удаление символа
                        } else {
                          newLine = editor.file.lines[editor.localUser.cursorPosition.y]
                                  .substring(0, editor.localUser.cursorPosition.x - 1) +
                              editor.file.lines[editor.localUser.cursorPosition.y]
                                  .substring(editor.localUser.cursorPosition.x);
                          editor.updateFileModel(
                              lineIndex: editor.localUser.cursorPosition.y, newText: newLine, inputLength: -1);
                        }
                        // удаление выделения
                      } else {
                        Selection select = editor.localUser.selection!.readyToWork;

                        //удаление конца первой строки
                        newLine = editor.file.lines[select.start.y].substring(0, select.start.x);
                        int oldLineLength = select.start.x;
                        // в случае, если выделение лишь на одной строке
                        if (select.end.y == select.start.y) {
                          newLine += editor.file.lines[select.start.y].substring(select.end.x);
                          editor.updateFileModel(
                              lineIndex: editor.localUser.cursorPosition.y, newText: newLine, inputLength: -1);
                          editor.updateLocalUser(newPosition: Point(oldLineLength, select.start.y), newSelection: null);
                          // выделение на нескольких строках
                        } else {
                          newLine += editor.file.lines[select.end.y].substring(select.end.x);
                          // удаление строк
                          deleteLines(startLineIndex: select.start.y + 1, endLineIndex: select.end.y + 1);
                          editor.updateFileModel(lineIndex: select.start.y, newText: newLine, inputLength: -1);
                          editor.updateLocalUser(newPosition: Point(oldLineLength, select.start.y), newSelection: null);
                        }
                      }
                      // добавление новой строки
                    } else if (keyEvent.logicalKey == LogicalKeyboardKey.enter) {
                      newLine = editor.file.lines[editor.localUser.cursorPosition.y]
                          .substring(0, editor.localUser.cursorPosition.x);
                      secondLine = editor.file.lines[editor.localUser.cursorPosition.y]
                          .substring(editor.localUser.cursorPosition.x);

                      editor.updateFileModel(
                          lineIndex: editor.localUser.cursorPosition.y, newText: newLine, inputLength: 0);
                      editor.updateLocalUser(newPosition: Point(0, editor.localUser.cursorPosition.y + 1));
                      //переносим остаток на новую линию
                      makeNewLine(previousLineIndex: editor.localUser.cursorPosition.y, startText: secondLine);
                      // управление стрелочками
                    } else {
                      keyboardNavigation(keyEvent);
                    }
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  itemCount: editor.file.lines.length,
                  itemBuilder: ((context, index) {
                    if (linesList.length > index) {
                      linesList[index] = GlobalKey<LineWidgetState>();
                    } else {
                      linesList.add(GlobalKey<LineWidgetState>());
                    }
                    return LineWidget(
                      key: linesList[index],
                      text: editor.file.lines[index],
                      index: index,
                      lineWidth: constraints.maxWidth,
                    );
                  }),
                  controller: scrollController,
                ),
              ),
            );
          }),
        ));
  }
}
