import Foundation

final class TodoListViewModel: ObservableObject {
    
    //MARK: - Properties
    @Observable var todoItems: [TodoItem] = []
    @Observable var showCompletedTasks: Bool = false
    @Observable var completedTasksCount: Int = 0
    
    private var uncompletedTodoItems: [TodoItem] = []
    
    private let fileCache: FileCacheProtocol
    
    //MARK: - Initialization
    init(fileCache: FileCacheProtocol = FileCache()) {
        self.fileCache = fileCache
        loadItems()
    }
    
    var tasksToShow: [TodoItem] {
        return showCompletedTasks ? todoItems : uncompletedTodoItems
    }
    
    //MARK: - Methods
    func toggleShowCompletedTasks() {
        showCompletedTasks.toggle()
        loadItems()
    }
    
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
    
    func moveItem(from sourceIndex: Int, to destinationIndex: Int) {
        if let item = fileCache.moveItem(from: sourceIndex, to: destinationIndex) {
            todoItems.remove(at: sourceIndex)
            todoItems.insert(item, at: destinationIndex)
            saveItems()
        }
    }
    
    func updateIsDone(from todoItem: TodoItem) -> TodoItem {
        let updateTodoItem = TodoItem(
            id: todoItem.id,
            text: todoItem.text,
            importance: todoItem.importance,
            deadline: todoItem.deadline,
            isDone: !todoItem.isDone,
            hexColor: todoItem.hexColor
        )
        addItem(updateTodoItem)
        loadItems()
        return updateTodoItem
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
            uncompletedTodoItems = todoItems.filter { !$0.isDone }
            completedTasksCount = todoItems.filter { $0.isDone }.count
        } catch {
            print("Failed to load to JSON")
        }
    }
}
