import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:polyscript/model/action.dart';
import 'package:polyscript/model/action_names.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/model/user_model.dart';

import '../file_model.dart';

/*

универсальный класс, описывающий действие замены текста
этим классом можно описать любое из следующих действий:

- Ввод текста
- Удаление текста
- Вставка текста
- Удаление выделения
- Замена выделенного текста

По сути данный класс, описывает только замену выделенного текста, 
однако подбирая правильно выделенный текст можно добиться всех остальных действий

*/

class ReplaceTextAction extends EditorAction {
  @override
  String get actionName => replaceText;

  List<String> insertingText;

  late EditorModel model;
  late Selection selectedRange;

  ReplaceTextAction(username, this.insertingText) : super(username);

  static ReplaceTextAction fromJson(dynamic json) => ReplaceTextAction(
        json["username"],
        json["text"].split("\n"),
      );

  @override
  void execute(EditorModel model) {
    this.model = model;
    selectedRange = model.users.firstWhere((user) => user.name == username).selection.copy();

    deleteSelectedText();
    updateUsersAfterDeleting();
    insertText();
    updateUsersAfterInserting();
  }

  void deleteSelectedText() {
    var prefix = model.file.lines[selectedRange.start.y].first.substring(0, selectedRange.start.x);
    var suffix = model.file.lines[selectedRange.end.y].first.substring(selectedRange.end.x);

    model.file.lines.removeRange(selectedRange.start.y, selectedRange.end.y + 1);
    model.file.lines.insert(selectedRange.start.y, Pair(prefix + suffix, GlobalKey()));
  }

  void updateUsersAfterDeleting() {
    for (var user in model.users) {
      user.cursorPosition = pointAfterDeleting(user.cursorPosition);
      user.selection.start = pointAfterDeleting(user.selection.start);
      user.selection.end = pointAfterDeleting(user.selection.end);
    }
  }

  Point<int> pointAfterDeleting(Point<int> point) {
    if (selectedRange.constaint(point)) {
      return selectedRange.start;
    } else if (point.y == selectedRange.end.y && point.x >= selectedRange.end.x) {
      return Point(selectedRange.start.x + point.x - selectedRange.end.x, selectedRange.start.y);
    } else if (point.y > selectedRange.end.y) {
      return Point(point.x, selectedRange.start.y + point.y - selectedRange.end.y);
    } else {
      return point;
    }
  }

  void insertText() {
    var prefix = model.file.lines[selectedRange.start.y].first.substring(0, selectedRange.start.x);
    var suffix = model.file.lines[selectedRange.start.y].first.substring(selectedRange.start.x);

    if (insertingText.length == 1) {
      model.file.lines[selectedRange.start.y] =
          Pair(prefix + insertingText[0] + suffix, model.file.lines[selectedRange.start.y].second);
    } else {
      model.file.lines[selectedRange.start.y] =
          Pair(prefix + insertingText[0], model.file.lines[selectedRange.start.y].second);

      for (int i = 1; i < insertingText.length - 1; i++) {
        model.file.lines.insert(selectedRange.start.y + i - 1, Pair(insertingText[i], GlobalKey()));
      }

      model.file.lines
          .insert(selectedRange.start.y + insertingText.length - 1, Pair(insertingText.last + suffix, GlobalKey()));
    }
  }

  void updateUsersAfterInserting() {
    for (var user in model.users) {
      user.cursorPosition = pointAfterInserting(user.cursorPosition);
      user.selection.start = pointAfterInserting(user.selection.start);
      user.selection.end = pointAfterInserting(user.selection.end);
    }
  }

  Point<int> pointAfterInserting(Point<int> point) {
    if (point.y == selectedRange.start.y && point.x >= selectedRange.start.x) {
      if (insertingText.length == 1) {
        return Point(insertingText.last.length + point.x, point.y + insertingText.length - 1);
      } else {
        return Point(insertingText.last.length + point.x - selectedRange.start.x, point.y + insertingText.length - 1);
      }
    } else if (point.y > selectedRange.start.y) {
      return Point(point.x, point.y + insertingText.length - 1);
    } else {
      return point;
    }
  }

  @override
  toJson() {
    return jsonEncode(
      {
        "action": actionName,
        "username": username,
        "text": insertingText.join("\n"),
      },
    );
  }
}
