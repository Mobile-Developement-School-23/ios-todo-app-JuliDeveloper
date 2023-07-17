import SwiftUI

enum Importance: String {
    case unimportant = "low"
    case normal = "basic"
    case important = "important"
}

struct TodoItem: Identifiable, Equatable {
    let id: UUID
    let text: String
    let importance: Importance
    let deadline: Date?
    var isDone: Bool
    
    static func getList() -> [TodoItem] {
        var list = [TodoItem]()
        
        list = DataManager.shared.mockTodoItems
        
        return list
    }
}
