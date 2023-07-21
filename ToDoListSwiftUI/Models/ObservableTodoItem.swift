import Foundation
import Combine

class ObservableTodoItem: ObservableObject, Equatable, Identifiable {
    @Published var item: TodoItem
    @Published var isPresenting = false
    
    init(item: TodoItem) {
        self.item = item
    }
    
    static func == (lhs: ObservableTodoItem, rhs: ObservableTodoItem) -> Bool {
        lhs.item.id == rhs.item.id
    }
}
