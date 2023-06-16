import Foundation

private let idKey = "id"
private let textKey = "text"
private let importanceKey = "importance"
private let deadlineKey = "deadline"
private let isDoneKey = "isDone"
private let createdAtKey = "createdAt"
private let changesAtKey = "changesAt"

enum Importance: String {
    case unimportant
    case normal
    case important
}

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let createdAt: Date
    let changesAt: Date?
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(),
        changesAt: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.changesAt = changesAt
    }
}

//MARK: - Convert TodoItem to/from JSON
extension TodoItem {
    var json: Any {
        var result: [String: Any] = [:]
        
        result[idKey] = id
        result[textKey] = text
        result[isDoneKey] = isDone
        
        if importance != Importance.normal {
            result[importanceKey] = importance.rawValue
        }
        
        if let deadlineInt = deadline?.dateIntValue {
            result[deadlineKey] = deadlineInt
        }
        
        if let createdInt = createdAt.dateIntValue {
            result[createdAtKey] = createdInt
        }
        
        if let changesInt = changesAt?.dateIntValue {
            result[changesAtKey] = changesInt
        }
        
        return result
    }
    
    static func parse(json: Any) -> TodoItem? {
        guard let json = json as? [String: Any],
              let id = json["id"] as? String,
              let text = json["text"] as? String,
              let createdAt = (json["createdAt"] as? Int)?.dateValue
        else {
            return nil
        }
        
        let importance = (json["importance"] as? String).flatMap(Importance.init(rawValue:)) ?? .normal
        let deadline = (json["deadline"] as? Int)?.dateValue
        let isDone = json["isDone"] as? Bool ?? false
        let changesAt = (json["changesAt"] as? Int)?.dateValue
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt
        )
    }
}
