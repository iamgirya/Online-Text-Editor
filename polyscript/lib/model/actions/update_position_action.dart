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

class UpdatePositionAction with EditorAction {
  @override
  // TODO: implement actionName
  String get actionName => "update_position";
  //Имя пользователя, инициировавшего действие
  @override
  late String username;
  //Новая позиция
  late Point<int> position;

  @override
  void execute(EditorModel model) {
    var userIndex = model.users.indexWhere((user) => user.name == username);

    if (userIndex != -1) {
      model.users[userIndex].cursorPosition = position;
      model.users[userIndex].selection = Selection(position, position);
    }
  }

  UpdatePositionAction(this.username, this.position);

  UpdatePositionAction.fromJson(dynamic json) {
    position = Point(json["position"][0], json["position"][1]);
    username = json["username"];
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
