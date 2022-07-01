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
  Point<int> start;
  Point<int> end;

  Selection get readyToWork {
    if (_isRevert) {
      return _getRevert;
    } else {
      return this;
    }
  }

  bool get _isRevert => (start.y > end.y || (start.y == end.y && start.x > end.x));
  Selection get _getRevert => Selection(end, start);
  bool get isEmpty => start == end;

  Selection(this.start, this.end);

  //проверка нахождения точки в области выделения
  bool constaint(Point<int> p) {
    return (p.y > start.y && p.y < end.y) ||
        (start.y == end.y && p.y == start.y && p.x > start.x && p.x < end.x) ||
        (start.y != end.y && ((p.y == start.y && p.x > start.x) || (p.y == end.y && p.x < end.x)));
  }
}
