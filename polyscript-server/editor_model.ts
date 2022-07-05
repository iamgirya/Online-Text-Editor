import { FileModel } from "./file_model"
import { User } from "./user_model"

export class EditorModel {
    file: FileModel
    users: User[]
    constructor(file: FileModel) {
        this.file = file
        this.users = []
    }
}