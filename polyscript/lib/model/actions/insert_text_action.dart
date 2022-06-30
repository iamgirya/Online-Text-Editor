import 'dart:convert';
import 'dart:math';

import 'package:polyscript/model/action.dart';
import 'package:polyscript/model/editor_model.dart';

class InsertTextAction implements EditorAction {
  @override
  late String username;
  late String text;
  late Point<int> position;

  InsertTextAction(this.username, this.text, this.position);

  InsertTextAction.fromJson(dynamic json) {
    username = json["username"];
    text = json["text"];
    position = Point(json["position"][0], json["position"][1]);
  }

  @override
  void execute(EditorModel model) {
    var lines = text.split("\n");

    var prefix = model.file.lines[position.y].substring(0, position.x);
    var suffix = model.file.lines[position.y].substring(position.x);

    if (lines.length == 1) {
      model.file.lines[position.y] = prefix + lines[0] + suffix;

      for (var user in model.users) {
        if (user.name == username) {
          user.cursorPosition = Point(position.x + text.length, position.y);
        } else {
          if (user.cursorPosition.y == position.y && user.cursorPosition.x > position.x) {
            user.cursorPosition = Point(user.cursorPosition.x + text.length, user.cursorPosition.y);
          }
        }
      }
    } else {
      model.file.lines[position.y] = prefix + lines[0];
      for (int i = 1; i < lines.length - 1; i++) {
        model.file.lines.insert(position.y + i - 1, lines[i]);
      }
      model.file.lines.insert(position.y + lines.length - 1, lines.last + suffix);

      for (var user in model.users) {
        if (user.name == username) {
          model.localUser.cursorPosition = Point(lines.last.length, position.y + lines.length - 1);
        } else {
          if (user.cursorPosition.y == position.y && user.cursorPosition.x > position.x) {
            user.cursorPosition = Point(user.cursorPosition.x + text.length, user.cursorPosition.y);
          } else if (user.cursorPosition.y > position.y) {
            user.cursorPosition = Point(user.cursorPosition.x, user.cursorPosition.y + lines.length);
          }
        }
      }
    }
  }

  @override
  dynamic toJson() {
    return jsonEncode(
      {
        "action": "insert_text",
        "username": username,
        "text": text,
        "position": [position.x, position.y],
      },
    );
  }
}
