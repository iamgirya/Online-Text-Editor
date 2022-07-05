import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:polyscript/model/action_names.dart';
import 'package:polyscript/model/actions/replace_text_action.dart';
import 'package:polyscript/model/actions/update_position_action.dart';
import 'package:polyscript/model/file_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'action.dart';
import 'user_model.dart';

final connectionAddress = Uri.parse("ws://127.0.0.1:8081");

class EditorModel extends ChangeNotifier {
  late FileModel file;
  late List<User> users;
  late String localUserName;
  late WebSocketChannel socket;
  Function? onUpdate;
  late Function(String?) onConnect;
  Queue<EditorAction> requestQueue = Queue();
  static const int queueMaxCount = 1;
  User get localUser => users.firstWhere((element) => element.name == localUserName);

  void updateLocalUser({Point<int>? newPosition, Selection? newSelection}) {
    if (newPosition != null || newSelection != null) {
      if (newSelection != null) {
        localUser.selection = newSelection;
      }

      notifyListeners();
    }
  }

  String getSelectedText() {
    String text = "";
    Selection selection = localUser.selection.readyToWork;
    if (selection.start.y == selection.end.y) {
      text = file.lines[selection.start.y].first.substring(selection.start.x, selection.end.x);
    } else {
      text = file.lines[selection.start.y].first.substring(selection.start.x);
      for (int i = selection.start.y+1; i < selection.end.y; i++) {
        text += "\n" + file.lines[i].first;
      }
      text += file.lines[selection.end.y].first.substring(0, selection.end.x);
    }
    return text;
  }

  void sendJSON(EditorAction actionToSend) {
    String json = actionToSend.toJson();

    // if (requestQueue.length < queueMaxCount &&
    //     !(requestQueue.isNotEmpty && (actionToSend is UpdatePositionAction) && requestQueue.last == actionToSend)) {
    requestQueue.add(actionToSend);
    socket.sink.add(json);
    //}
    //print(requestQueue.length);
  }

  EditorModel.createFile(this.localUserName, this.onConnect) {
    users = [
      User(
        const Point(0, 0),
        localUserName,
        Colors.indigo,
        Selection(const Point(0, 0), const Point(0, 0)),
      ),
    ];

    file = FileModel("file_name", -1, [""]);

    socket = WebSocketChannel.connect(connectionAddress);

    socket.stream.listen(listenServer, onError: onServerError);

    socket.sink.add(
      jsonEncode(
        {
          "action": createFile,
          "username": localUserName,
        },
      ),
    );
  }

  EditorModel.connectFile(this.localUserName, int fileCode, this.onConnect) {
    users = [
      User(
        const Point(0, 0),
        localUserName,
        Colors.indigo,
        Selection(const Point(0, 0), const Point(0, 0)),
      ),
    ];

    file = FileModel("file_name", -1, []);

    socket = WebSocketChannel.connect(connectionAddress);

    socket.stream.listen(listenServer, onError: onServerError);

    socket.sink.add(
      jsonEncode(
        {
          "action": connectToFile,
          "username": localUserName,
          "file_code": fileCode,
        },
      ),
    );
  }

  void onServerError(stack) {
    onConnect("Не удалось подключиться к серверу");
  }

  void listenServer(message) {
    EditorAction? action;
    var json = jsonDecode(message);

    switch (json["action"]) {
      case createFile:
        file.fileCode = json["file_code"];
        onConnect(null);
        break;
      case updateFileState:
        var jsonUsers = json["users"];
        var fileLines = json["file"];

        for (var user in jsonUsers) {
          var userJson = jsonDecode(user);
          var point = userJson["position"];
          users.add(User(
            Point(point[0], point[1]),
            userJson["username"],
            Colors.indigo,
            Selection(
              const Point(0, 0),
              const Point(0, 0),
            ),
          ));
        }

        for (String line in fileLines) {
          file.lines.add(Pair(line, GlobalKey()));
        }
        onConnect(null);
        break;

      case error:
        onConnect(json["error_message"]);
        break;

      case userConnect:
        users.add(User(
          const Point(0, 0),
          json["username"],
          Colors.indigo,
          Selection(
            const Point(0, 0),
            const Point(0, 0),
          ),
        ));
        notifyListeners();
        break;

      case userDisconnect:
        users.removeWhere((user) => user.name == json["username"]);
        notifyListeners();
        break;

      case replaceText:
        action = ReplaceTextAction.fromJson(json);
        action.execute(this);
        notifyListeners();
        break;

      case updatePosition:
        action = UpdatePositionAction.fromJson(json);
        action.execute(this);
        notifyListeners();
        break;
    }

    if (onUpdate != null) {
      onUpdate!();
    }

    if (requestQueue.isNotEmpty && action != null && (action == requestQueue.first)) {
      requestQueue.removeFirst();
    }
  }
}
