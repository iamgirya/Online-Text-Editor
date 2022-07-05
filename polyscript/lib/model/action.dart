import 'package:polyscript/model/editor_model.dart';

class EditorActionInterface {
  String get actionName => "";

  void execute(EditorModel model) => {};

  dynamic toJson() => {};
}

class EditorAction implements EditorActionInterface {
  String username = "";

  EditorAction(this.username);

  @override
  String get actionName => "";

  @override
  void execute(EditorModel model) => {};

  @override
  dynamic toJson() => {};

  @override
  bool operator ==(other) => actionName == (other as EditorAction).actionName && (other.username == username);

  @override
  int get hashCode => username.hashCode & actionName.hashCode;
}
