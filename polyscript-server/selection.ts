import { Point } from "./point"

export class Selection {
    start: Point
    end: Point
    constructor(start: Point, end: Point) {
        if (start.y < end.y || (start.y == end.y && start.x < end.x)) {
            this.start = start
            this.end = end
        } else {
            this.start = end
            this.end = start
        }
    }

    //проверка нахождения точки в области выделения
    constaint(p: Point) {
        console.log(p)
        return (p.y > this.start.y && p.y < this.end.y) ||
            (this.start.y == this.end.y && p.y == this.start.y && p.x > this.start.x && p.x < this.end.x) ||
            (this.start.y != this.end.y && ((p.y == this.start.y && p.x > this.start.x) || (p.y == this.end.y && p.x < this.end.x)));
  }
}