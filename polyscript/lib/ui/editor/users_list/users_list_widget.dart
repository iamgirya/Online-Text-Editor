import 'package:flutter/material.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/ui/editor/editor_inherit.dart';

import 'user_widget.dart';

class UsersListWidget extends StatefulWidget {
  const UsersListWidget({Key? key}) : super(key: key);

  @override
  State<UsersListWidget> createState() => _UsersListWidgetState();
}

class _UsersListWidgetState extends State<UsersListWidget> {
  @override
  Widget build(BuildContext context) {
    var editor = EditorInherit.of(context).editor;

    return Row(
      children: loadUsers(context, editor),
    );
  }

  List<Widget> loadUsers(BuildContext context, EditorModel editor) {
    return editor.users.map((user) => UserWidget(user: user)).toList();
  }
}
