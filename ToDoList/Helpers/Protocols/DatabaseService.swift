import Foundation

protocol DatabaseService {
    func addItem(_ item: TodoItem) throws
    func updateItem(_ item: TodoItem) throws
    func deleteItem(_ item: TodoItem) throws
    func loadItems(_ completion: (Result<[TodoItem], Error>) -> Void) throws
    func saveItems(_ items: [TodoItem]) throws
}
