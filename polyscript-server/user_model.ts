import  { Selection } from "./selection"
import { Point } from './point';
import { WebSocket } from "ws"

export class User {
    username: string
    cursorPosition: Point
    selection: Selection
    socket: WebSocket
    fileCode: number

    constructor(name: string, socket: WebSocket, fileCode: number) {
        this.username = name
        this.cursorPosition = new Point(0,0)
        this.selection = new Selection(this.cursorPosition, this.cursorPosition)
        this.socket = socket
        this.fileCode = fileCode
    }

    toJson() {
        return JSON.stringify({
            "username": this.username,
            "position": [this.cursorPosition.x, this.cursorPosition.y],
            "selection": [this.selection.start.x, this.selection.start.y, this.selection.end.x, this.selection.end.y],
        })
    }
}