import Foundation

final class TodoListViewModel: ObservableObject {
    
    //MARK: - Properties
    @Observable var todoItems: [TodoItem] = []
    
    private let fileCache: FileCacheProtocol
    
    //MARK: - Initialization
    init(fileCache: FileCacheProtocol = FileCache()) {
        self.fileCache = fileCache
        loadItems()
    }
    
    //MARK: - Methods
    func addItem(_ item: TodoItem) {
        if let newItem = fileCache.addItem(item) {
            todoItems.append(newItem)
            saveItems()
            loadItems()
        }
    }
    
    func deleteItem(with id: String) {
        if let _ = fileCache.deleteItem(with: id) {
            todoItems.removeAll { $0.id == id }
            saveItems()
            loadItems()
        }
    }
    
    func saveItems() {
        do {
            try fileCache.saveToJson(to: "todoItems")
        } catch {
            print("Failed to save to JSON")
        }
    }
    
    func loadItems() {
        do {
            try fileCache.loadFromJson(from: "todoItems")
            todoItems = fileCache.todoItemsList
        } catch {
            print("Failed to load to JSON")
        }
    }
}