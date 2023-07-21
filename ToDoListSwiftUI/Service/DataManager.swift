import SwiftUI

final class DataManager {
    static let shared = DataManager()
    
    let mockTodoItems = [
        TodoItem(id: UUID(), text: "Полить цветы", importance: .important, deadline: Date(), isDone: false),
        TodoItem(id: UUID(), text: "Выгулять собаку", importance: .normal, deadline: Date().addingTimeInterval(86400), isDone: false),
        TodoItem(id: UUID(), text: "Купить молоко", importance: .unimportant, deadline: nil, isDone: true),
        TodoItem(id: UUID(), text: "Прочитать книгу", importance: .important, deadline: Date().addingTimeInterval(3*86400), isDone: true),
        TodoItem(id: UUID(), text: "Позвонить другу", importance: .unimportant, deadline: nil, isDone: false),
        TodoItem(id: UUID(), text: "Заказать пиццу", importance: .normal, deadline: Date(), isDone: true),
        TodoItem(id: UUID(), text: "Подготовить отчет", importance: .important, deadline: Date().addingTimeInterval(2*86400), isDone: false),
        TodoItem(id: UUID(), text: "Сходить в зал", importance: .normal, deadline: nil, isDone: false),
        TodoItem(id: UUID(), text: "Заплатить за интернет", importance: .unimportant, deadline: Date().addingTimeInterval(5*86400), isDone: true),
        TodoItem(id: UUID(), text: "Посетить врача", importance: .important, deadline: Date().addingTimeInterval(4*86400), isDone: false)
    ]
    
    private init() {}
}
