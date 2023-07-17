import UIKit

enum Importance: String {
    case unimportant = "low"
    case normal = "basic"
    case important = "important"
}

struct TodoItem {
    let id: Int
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let color: UIColor
    
    static func getList() -> [TodoItem] {
        var list = [TodoItem]()
        
        let ids = DataManager.shared.ids.shuffled()
        let text = DataManager.shared.texts.shuffled()
        let color = DataManager.shared.colors.shuffled()
        let importance = DataManager.shared.importance
        let isDone = DataManager.shared.isDone
        
        let count = min(
            DataManager.shared.ids.count,
            DataManager.shared.texts.count,
            DataManager.shared.colors.count
        )
        
        for index in 0..<count {
            list.append(
                TodoItem(
                    id: ids[index],
                    text: text[index],
                    importance: importance.randomElement() ?? .normal,
                    deadline: nil,
                    isDone: isDone.randomElement() ?? false,
                    color: color[index]
                )
            )
        }
        
        return list
    }
}
