import Foundation

protocol FileCacheProtocol {
    var todoItemsList: [TodoItem] { get }
    func addItem(_ item: TodoItem) -> TodoItem?
    func deleteItem(with id: String) -> TodoItem?
    func saveToJson(to file: String) throws
    func loadFromJson(from file: String) throws
}
