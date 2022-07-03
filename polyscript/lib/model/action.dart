import 'package:polyscript/model/editor_model.dart';

mixin EditorAction {
  String get actionName => "";
  //имя пользователя, который инициировал действие
  String username = "";
  //метод, выполняющий преобразования над моделью
  void execute(EditorModel model) => {};

  //метод, преобразующий информацию о действии в JSON для отправки на сервер
  dynamic toJson() => {};

  @override
  bool operator ==(other) => actionName == (other as EditorAction).actionName && (other.username == username);
  @override
  int get hashCode => username.hashCode+actionName.hashCode;
}
