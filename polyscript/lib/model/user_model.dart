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
  Point<int> start = const Point(-1,-1);
  Point<int> end = const Point(-1,-1);

  Selection.none();
  Selection(this.start, this.end);
  
}
