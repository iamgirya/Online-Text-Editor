import 'dart:convert';
import 'dart:math';

import 'package:polyscript/model/action.dart';
import 'package:polyscript/model/action_names.dart';
import 'package:polyscript/model/editor_model.dart';

import '../user_model.dart';

class UpdatePositionAction extends EditorAction {
  @override
  String get actionName => updatePosition;

  Point<int> position;

  UpdatePositionAction(username, this.position) : super(username);

  static UpdatePositionAction fromJson(dynamic json) =>
      UpdatePositionAction(json["username"], Point(json["position"][0], json["position"][1]));

  @override
  void execute(EditorModel model) {
    var movedUser = model.users.firstWhere((user) => user.name == username);
    movedUser.cursorPosition = position;
    movedUser.selection = Selection(position, position);
  }

  @override
  toJson() {
    return jsonEncode(
      {
        "action": actionName,
        "username": username,
        "position": [position.x, position.y],
      },
    );
  }
}
