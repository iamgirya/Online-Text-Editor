import 'package:polyscript/model/editor_model.dart';

class EditorAction {
  static String get actionName => "";
  //имя пользователя, который инициировал действие
  String username = "";
  //метод, выполняющий преобразования над моделью
  void execute(EditorModel model) => {};

  //метод, преобразующий информацию о действии в JSON для отправки на сервер
  dynamic toJson() => {};
}
