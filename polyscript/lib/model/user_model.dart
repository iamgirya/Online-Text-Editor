import 'dart:math';
import 'dart:ui';

class User {
  String name;
  Color color;
  Point<int> cursorPosition;
  Selection selection;
  User(this.cursorPosition, this.name, this.color, this.selection);
}

class Selection {
  late Point<int> start;
  late Point<int> end;

  bool get isEmpty => start == end;

  Selection(start, end) {
    if (start.y > end.y || (start.y == end.y && start.x > end.x)) {
      this.start = end;
      this.end = start;
    } else {
      this.start = start;
      this.end = end;
    }
  }

  bool constaint(Point<int> p) {
    return (p.y > start.y && p.y < end.y) ||
        (start.y == end.y && p.y == start.y && p.x > start.x && p.x < end.x) ||
        (start.y != end.y && ((p.y == start.y && p.x > start.x) || (p.y == end.y && p.x < end.x)));
  }

  Selection copy() {
    return Selection(start, end);
  }
}
