import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:polyscript/model/action.dart';
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

class ReplaceTextAction with EditorAction {
  @override
  // TODO: implement actionName
  String get actionName => "replace_text";
  //Имя пользователя, инициировавшего действие
  @override
  late String username;
  //Текст, на который будет заменена выделенная область
  late String insertingText;
  //Область, которая была выделена пользователем в момент выполнения действия
  late Selection selectedRange;

  //TODO: - реализовать смещение выделений у пользователей
  @override
  void execute(EditorModel model) {
    deleteSelection(model);
    insertText(model);
  }

  ReplaceTextAction(this.username, this.insertingText, this.selectedRange);

  ReplaceTextAction.fromJson(dynamic json) {
    var selectionPoints = json["selection"];

    username = json["username"];
    insertingText = json["text"];
    selectedRange =
        Selection(Point(selectionPoints[0], selectionPoints[1]), Point(selectionPoints[2], selectionPoints[3]));
  }

  @override
  toJson() {
    return jsonEncode(
      {
        "action": actionName,
        "username": username,
        "text": insertingText,
        "selection": [selectedRange.start.x, selectedRange.start.y, selectedRange.end.x, selectedRange.end.y],
      },
    );
  }

  void deleteSelection(EditorModel model) {
    if (selectedRange.start == selectedRange.end) {
      return;
    }

    var prefix = model.file.lines[selectedRange.start.y].first.substring(0, selectedRange.start.x);
    var suffix = model.file.lines[selectedRange.end.y].first.substring(selectedRange.end.x);

    model.file.lines.removeRange(selectedRange.start.y, selectedRange.end.y+1);

    model.file.lines.insert(selectedRange.start.y, Pair(prefix + suffix, GlobalKey()));

    for (var user in model.users) {
      if (user.name == username || selectedRange.constaint(user.cursorPosition)) {
        user.cursorPosition = Point(
          selectedRange.start.x,
          selectedRange.start.y,
        );
        if (user.name == username) {
          //user.selection = Selection(user.cursorPosition, user.cursorPosition);
        } else {
          //TODO: - сделать нормальное обновление выделения
          //user.selection = Selection(user.cursorPosition, user.cursorPosition);
        }
      } else {
        if (user.cursorPosition.y == selectedRange.end.y && user.cursorPosition.x >= selectedRange.end.x) {
          user.cursorPosition = Point(
            prefix.length + user.cursorPosition.x - selectedRange.end.x,
            selectedRange.start.y,
          );
          //TODO: - сделать нормальное обновление выделения
          //user.selection = Selection(user.cursorPosition, user.cursorPosition);
        } else if (user.cursorPosition.y > selectedRange.end.y) {
          user.cursorPosition = Point(
            user.cursorPosition.x,
            user.cursorPosition.y - (selectedRange.end.y - selectedRange.start.y),
          );
          //TODO: - сделать нормальное обновление выделения
          //user.selection = Selection(user.cursorPosition, user.cursorPosition);
        }
      }
    }
  }

  void insertText(EditorModel model) {
    var lines = insertingText.split("\n");

    var prefix = model.file.lines[selectedRange.start.y].first.substring(0, selectedRange.start.x);
    var suffix = model.file.lines[selectedRange.start.y].first.substring(selectedRange.start.x);

    if (lines.length == 1) {
      model.file.lines[selectedRange.start.y] = Pair(prefix + lines[0] + suffix, model.file.lines[selectedRange.start.y].second);

      for (var user in model.users) {
        if (user.name == username) {
          user.cursorPosition = Point(selectedRange.start.x + insertingText.length, selectedRange.start.y);
          //user.selection = Selection(user.cursorPosition, user.cursorPosition);
        } else {
          if (user.cursorPosition.y == selectedRange.start.y && user.cursorPosition.x > selectedRange.start.x) {
            user.cursorPosition = Point(user.cursorPosition.x + insertingText.length, user.cursorPosition.y);
            //TODO: - сделать нормальное обновление выделения
            //user.selection = Selection(user.cursorPosition, user.cursorPosition);
          }
        }
      }
    } else {
      model.file.lines[selectedRange.start.y] = Pair(prefix + lines[0], model.file.lines[selectedRange.start.y].second);
      for (int i = 1; i < lines.length - 1; i++) {
        model.file.lines.insert(selectedRange.start.y + i - 1, Pair(lines[i], GlobalKey()));
      }
      model.file.lines.insert(selectedRange.start.y + lines.length - 1, Pair(lines.last + suffix, GlobalKey()));

      for (var user in model.users) {
        if (user.name == username) {
          user.cursorPosition = Point(lines.last.length, selectedRange.start.y + lines.length - 1);
          //user.selection = Selection(user.cursorPosition, user.cursorPosition);
        } else {
          if (user.cursorPosition.y == selectedRange.start.y && user.cursorPosition.x > selectedRange.start.x) {
            user.cursorPosition = Point(lines.last.length + user.cursorPosition.x - selectedRange.end.x,
                user.cursorPosition.y + lines.length - 1);
            //TODO: - сделать нормальное обновление выделения
            //user.selection = Selection(user.cursorPosition, user.cursorPosition);
          } else if (user.cursorPosition.y > selectedRange.start.y) {
            user.cursorPosition = Point(user.cursorPosition.x, user.cursorPosition.y + lines.length - 1);
            //TODO: - сделать нормальное обновление выделения
            //user.selection = Selection(user.cursorPosition, user.cursorPosition);
          }
        }
      }
    }
  }
}
