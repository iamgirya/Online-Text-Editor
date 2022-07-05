import 'package:flutter/material.dart';
import 'package:polyscript/model/editor_model.dart';
import 'package:polyscript/ui/colors.dart';
import 'package:polyscript/ui/editor/editor_inherit.dart';
import 'package:polyscript/ui/editor/users_list/users_list_widget.dart';
import 'package:polyscript/ui/styles.dart';

class EditorBar extends StatefulWidget {
  const EditorBar({Key? key}) : super(key: key);

  @override
  State<EditorBar> createState() => _EditorBarState();
}

class _EditorBarState extends State<EditorBar> {
  late EditorModel editor;
  @override
  Widget build(BuildContext context) {
    editor = EditorInherit.of(context).editor;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 16),
          child: SizedBox(
            height: 42,
            child: Row(
              children: [
                exitButton,
                const SizedBox(width: 0),
                fileName,
                const SizedBox(width: 8),
                fileCode,
                const Spacer(),
                const UsersListWidget(),
              ],
            ),
          ),
        ),
        Container(
          height: 2,
          color: divider,
        ),
      ],
    );
  }

  Widget get fileName {
    return Text(
      editor.file.name,
      style: textStyle,
    );
  }

  Widget get fileCode {
    return Text(
      editor.file.fileCode.toString(),
      style: indexStyle,
    );
  }

  Widget get exitButton {
    return IconButton(
      iconSize: 16,
      onPressed: () {
        editor.close();
        Navigator.pop(context);
      },
      splashRadius: 16,
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
      ),
    );
  }
}
