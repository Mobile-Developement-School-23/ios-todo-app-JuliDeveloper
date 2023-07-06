import Foundation

struct TodoItemListResult: Codable {
    let status: String
    let list: [TodoItemResult]
    let revision: Int32
}

struct TodoItemResult: Codable {
    let id: UUID
    let text: String
    let importance: ImportanceResult
    let deadline: Int64?
    let done: Bool
    let color: String?
    let createdAt: Int64
    let changeAt: Int64
    let lastUpdatedBy: String
    
    enum Keys: String, CodingKey {
        case createdAt = "created_at"
        case changeAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }
    
    func convert() -> TodoItem {
        let priority: Importance
        
        if self.importance == .low {
            priority = .unimportant
        } else if self.importance == .basic {
            priority = .normal
        } else {
            priority = .important
        }
        
        return TodoItem(
            id: self.id.uuidString,
            text: self.text,
            importance: priority,
            deadline: Int(self.deadline ?? 0).dateValue,
            isDone: self.done,
            createdAt: Int(self.createdAt).dateValue ?? Date(),
            changesAt: Int(self.changeAt).dateValue,
            hexColor: self.color ?? ""
        )
    }
}

enum ImportanceResult: String, Codable {
    case low
    case basic
    case important
}
