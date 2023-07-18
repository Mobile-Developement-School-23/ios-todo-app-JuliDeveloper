import SwiftUI

enum Importance: String, CaseIterable, Identifiable {
    case unimportant = "low"
    case normal = "basic"
    case important = "important"
    
    var id: Importance { self }
}

struct TodoItem: Identifiable, Equatable {
    let id: UUID
    var text: String
    var importance: Importance
    var deadline: Date?
    var isDone: Bool
    
    static func getList() -> [TodoItem] {
        var list = [TodoItem]()
        
        list = DataManager.shared.mockTodoItems
        
        return list
    }
}
