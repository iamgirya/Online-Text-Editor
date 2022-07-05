import { Point } from "./point"

export class Selection {
    start: Point
    end: Point
  
    constructor(start: Point, end: Point) {
      if (start.y > end.y || (start.y == end.y && start.x > end.x)) {
        this.start = end;
        this.end = start;
      } else {
        this.start = start;
        this.end = end;
      }
    }
  
    get isEmpty () { return this.start == this.end }

    constaint(p: Point) {
      return (p.y > this.start.y && p.y < this.end.y) ||
          (this.start.y == this.end.y && p.y == this.start.y && p.x > this.start.x && p.x < this.end.x) ||
          (this.start.y != this.end.y && ((p.y == this.start.y && p.x > this.start.x) || (p.y == this.end.y && p.x < this.end.x)));
    }

    copy() {
        return new Selection(this.start, this.end);
    }
}