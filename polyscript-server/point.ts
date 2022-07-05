export class Point {
    x: number
    y: number
    constructor(x: number,y: number) {
        this.x = x
        this.y = y
    }

    add(p: Point) {
        return new Point(this.x + p.x, this.y + p.y)
    }
}
