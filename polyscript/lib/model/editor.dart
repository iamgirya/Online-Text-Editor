import 'package:web_socket_channel/web_socket_channel.dart';

import 'user.dart';

class Editor {
  late int fileCode;
  late String text;
  late List<User> users;
  late WebSocketChannel socket;
  User localUser;

  Editor.createFile(this.localUser) {
    socket = WebSocketChannel.connect(Uri.parse("ws://127.0.0.1:8081"));
    fileCode = -1;
    text = "";
    users = [];
  }
}
