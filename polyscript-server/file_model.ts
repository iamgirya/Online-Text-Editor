export class FileModel {
    name: string
    code: number
    lines: string[]

    constructor(name: string, code: number, lines: string[]) {
        this.name = name
        this.code = code
        this.lines = lines
    }
}