import 'dart:convert';
import 'dart:math';

import 'package:polyscript/model/actions/replace_text_action.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/model/user_model.dart';

import '../action_names.dart';

class ClearTextAction extends ReplaceTextAction {
  @override
  String get actionName => clearText;

  ClearTextAction(username) : super(username, [""]);

  static ClearTextAction fromJson(json) {
    return ClearTextAction(json["username"]);
  }

  @override
  void execute(EditorModel model) {
    this.model = model;
    selectedRange = initSelectionForDeletingRange(model);

    deleteSelectedText();
    updateUsersAfterDeleting();
    insertText();
    updateUsersAfterInserting();
  }

  Selection initSelectionForDeletingRange(EditorModel model) {
    var userSelection = model.users.firstWhere((user) => user.name == username).selection.copy();

    if (userSelection.isEmpty) {
      if (userSelection.start.x == 0 && userSelection.start.y != 0) {
        return Selection(
          userSelection.start + Point(model.file.lines[userSelection.start.y - 1].first.length, -1),
          userSelection.start,
        );
      } else if (userSelection.start.x != 0) {
        return Selection(
          userSelection.start - const Point(1, 0),
          userSelection.start,
        );
      } else {
        return userSelection;
      }
    } else {
      return userSelection;
    }
  }

  @override
  toJson() {
    return jsonEncode({"action": actionName, "username": username});
  }
}
