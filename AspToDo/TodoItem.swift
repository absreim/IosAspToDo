//
//  TodoItem.swift
//  AspToDo
//
//  Created by Brook Li on 11/12/20.
//

struct TodoItem: Codable {
    var id: Int
    var name: String
    var isComplete: Bool
    init? (json: [String: Any]) {
        guard let id = json["id"] as? Int,
              let name = json["name"] as? String,
              let isComplete = json["isComplete"] as? Bool
        else {
            return nil
        }
        self.id = id
        self.name = name
        self.isComplete = isComplete
    }
}
