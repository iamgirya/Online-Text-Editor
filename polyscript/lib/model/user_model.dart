import 'dart:math';
import 'dart:ui';

class User {
  String name;
  Color color;
  Point<int> cursorPosition;
  Selection? selection;
  User(this.cursorPosition, this.name, this.color, {this.selection});
}

class Selection {
  Point<int> start;
  Point<int> end;

  Selection(this.start, this.end);
}
