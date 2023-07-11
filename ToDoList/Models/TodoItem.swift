import Foundation
import SQLite3

private let idKey = "id"
private let textKey = "text"
private let importanceKey = "importance"
private let deadlineKey = "deadline"
private let isDoneKey = "done"
private let createdAtKey = "created_at"
private let changesAtKey = "changed_at"
private let hexColorKey = "color"
private let lastUpdatedByKey = "last_updated_by"

enum Importance: String {
    case unimportant = "low"
    case normal = "basic"
    case important = "important"
}

struct TodoItem {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let createdAt: Date
    let changesAt: Date?
    let hexColor: String
    let lastUpdatedBy: String
    
    init(
        id: String = UUID().uuidString,
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(),
        changesAt: Date? = nil,
        hexColor: String = "#000000",
        lastUpdatedBy: String
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.changesAt = changesAt
        self.hexColor = hexColor
        self.lastUpdatedBy = lastUpdatedBy
    }
}

// MARK: - Convert TodoItem to/from JSON
extension TodoItem {
    var json: [String: Any] {
        var result: [String: Any] = [:]

        result[idKey] = id
        result[textKey] = text
        result[isDoneKey] = isDone
        result[hexColorKey] = hexColor
        result[importanceKey] = importance.rawValue
        result[lastUpdatedByKey] = lastUpdatedBy

        if let deadlineInt = deadline?.dateIntValue {
            result[deadlineKey] = Int64(deadlineInt)
        }

        if let createdInt = createdAt.dateIntValue {
            result[createdAtKey] = Int64(createdInt)
        }

        if changesAt == nil {
            let changesInt = Date().dateIntValue
            result[changesAtKey] = Int64(changesInt ?? 0)
        } else {
            result[changesAtKey] = Int64(changesAt?.dateIntValue ?? 0)
        }
        
        return result
    }
    
    init?(json: [String: Any]) {
        guard let id = json[idKey] as? String,
              let text = json[textKey] as? String,
              let isDone = json[isDoneKey] as? Bool,
              let hexColor = json[hexColorKey] as? String,
              let createdAt = (json[createdAtKey] as? Int)?.dateValue,
              let lastUpdatedBy = json[lastUpdatedByKey] as? String
        else {
            return nil
        }
        
        let importance = (json[importanceKey] as? String).flatMap(Importance.init(rawValue:)) ?? .normal
        let deadline = (json[deadlineKey] as? Int)?.dateValue
        let changesAt = (json[changesAtKey] as? Int)?.dateValue
        
        self.init(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt,
            hexColor: hexColor,
            lastUpdatedBy: lastUpdatedBy
        )
    }
    
    static func parse(json: Any) -> TodoItem? {
        guard let json = json as? [String: Any],
              let id = json[idKey] as? String,
              let text = json[textKey] as? String,
              let isDone = json[isDoneKey] as? Bool,
              let createdAt = (json[createdAtKey] as? Int)?.dateValue,
              let lastUpdatedBy = json[lastUpdatedByKey] as? String
        else {
            return nil
        }

        let importance = (json[importanceKey] as? String).flatMap(Importance.init(rawValue:)) ?? .normal
        let deadline = (json[deadlineKey] as? Int)?.dateValue
        let changesAt = (json[changesAtKey] as? Int)?.dateValue
        let hexColor = json[hexColorKey] as? String ?? "#000000"
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt,
            hexColor: hexColor,
            lastUpdatedBy: lastUpdatedBy
        )
    }
}

// MARK: - Convert TodoItem to/from CSV
extension TodoItem {
    var csv: String {
        let textCsv = text.replacingOccurrences(of: ",", with: "|")
        let importanceString = importance != .normal ? importance.rawValue : ""
        let isDoneString = isDone ? "true" : "false"
        let deadlineString = deadline != nil ? String(deadline?.dateIntValue ?? 0) : ""
        let createdAtString = String(createdAt.dateIntValue ?? 0)
        let changesAtString = changesAt != nil ? String(changesAt?.dateIntValue ?? 0) : ""
        
        return "\(id),\(textCsv),\(importanceString),\(deadlineString),\(isDoneString),\(createdAtString),\(changesAtString),\(hexColor)"
    }
    
    init?(csv: String) {
        let strings = csv.components(separatedBy: ",")
        
        guard strings.count == 8 else {
            return nil
        }
        
        let id = strings[0]
        let text = strings[1].replacingOccurrences(of: "|", with: ",")
        let importanceString = strings[2].isEmpty ? Importance.normal.rawValue : strings[2]
        let deadline = strings[3].isEmpty ? nil : Int(strings[3])?.dateValue
        let changesAt = strings[6].isEmpty ? nil : Int(strings[6])?.dateValue
        let hexColor = strings[7]
        
        guard let importance = Importance(rawValue: importanceString),
              let isDone = Bool(strings[4]),
              let createdAt = Int(strings[5])?.dateValue
        else {
            return nil
        }
        
        self.init(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt,
            hexColor: hexColor,
            lastUpdatedBy: ""
        )
    }
    
    static func parse(csv: String) -> TodoItem? {
        let strings = csv.components(separatedBy: ",")
        
        guard strings.count == 8 else {
            return nil
        }
        
        let id = strings[0]
        let text = strings[1].replacingOccurrences(of: "|", with: ",")
        let importanceString = strings[2].isEmpty ? Importance.normal.rawValue : strings[2]
        let deadline = strings[3].isEmpty ? nil : Int(strings[3])?.dateValue
        let changesAt = strings[6].isEmpty ? nil : Int(strings[6])?.dateValue
        let hexColor = strings[7]
        
        guard let importance = Importance(rawValue: importanceString),
              let isDone = Bool(strings[4]),
              let createdAt = Int(strings[5])?.dateValue
        else {
            return nil
        }
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changesAt: changesAt,
            hexColor: hexColor,
            lastUpdatedBy: ""
        )
    }
}

// MARK: - Convert TodoItem to SQLite3
extension TodoItem {
    var sqlReplaceStatement: String {
        let text = self.text.replacingOccurrences(of: "'", with: "''")
        let importanceString = self.importance.rawValue
        let isDoneString = self.isDone ? "1" : "0"
        let deadlineString = deadline != nil ? "'\(String(describing: self.deadline))'" : "NULL"
        let createdAtString = "'\(String(describing: self.createdAt))'"
        let changesAtString = changesAt != nil ? "'\(String(describing: self.changesAt))'" : "NULL"
        
        return """
        REPLACE INTO TodoItem (id, text, importance, deadline, isDone, createdAt, changesAt, hexColor, lastUpdatedBy)
        VALUES ('\(id)', '\(text)', '\(importanceString)', \(deadlineString), \(isDoneString), \(createdAtString), \(changesAtString), '\(hexColor)', '\(lastUpdatedBy)');
        """
    }
}
