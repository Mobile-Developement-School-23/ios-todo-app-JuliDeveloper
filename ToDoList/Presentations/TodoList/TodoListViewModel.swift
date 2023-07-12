import Foundation

protocol TodoListViewModelSQLiteProtocol {
    var todoList: [TodoItem] { get }
    var tasksToShow: [TodoItem] { get }
    var completedListCount: Int { get }
    func addItem(_ item: TodoItem)
    func updateItem(_ item: TodoItem)
    func deleteItem(_ item: TodoItem)
    func loadData()
    func saveData()
    func updateItemIsDone(from todoItem: TodoItem) -> TodoItem
    func toggleShowCompletedList()
    func bindTodoList(_ update: @escaping ([TodoItem]) -> Void)
    func bindCompletedTodoListCount(_ update: @escaping (Int) -> Void)
}

final class TodoListViewModel: ObservableObject {
    
    // MARK: - Properties
    @Observable var todoItems: [TodoItem] = []
    @Observable var showCompletedTasks: Bool = false
    @Observable var completedTasksCount: Int = 0
            
    private let fileCache: FileCacheSQLiteProtocol
            
    // MARK: - Initialization
    init(fileCache: FileCacheSQLiteProtocol = FileCache()) {
        self.fileCache = fileCache
        
        loadData()
    }
}

// Methods for work with SQLite3
extension TodoListViewModel: TodoListViewModelSQLiteProtocol {
    var todoList: [TodoItem] {
        todoItems
    }
    
    var tasksToShow: [TodoItem] {
        return showCompletedTasks ? todoItems : todoItems.filter { !$0.isDone }
    }
    
    var completedListCount: Int {
        completedTasksCount
    }
    
    func addItem(_ item: TodoItem) {
        todoItems.append(item)
        fileCache.insertItemDb(item)
        loadData()
    }
    
    func updateItem(_ item: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[index] = item
            fileCache.updateItemDb(item)
        }
        loadData()
    }
    
    func deleteItem(_ item: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems.remove(at: index)
            fileCache.deleteItemDb(todoItem: item)
        }
        loadData()
    }
    
    func loadData() {
        fileCache.loadFromDb()
        todoItems = fileCache.todoItemsDb
        completedTasksCount = todoItems.filter({ $0.isDone }).count
    }
    
    func saveData() {
        fileCache.saveToDb(items: todoItems)
        loadData()
    }
    
    func updateItemIsDone(from todoItem: TodoItem) -> TodoItem {
        return TodoItem(
            id: todoItem.id,
            text: todoItem.text,
            importance: todoItem.importance,
            deadline: todoItem.deadline,
            isDone: !todoItem.isDone,
            createdAt: todoItem.createdAt,
            changesAt: todoItem.changesAt,
            hexColor: todoItem.hexColor,
            lastUpdatedBy: todoItem.lastUpdatedBy
        )
    }
    
    func toggleShowCompletedList() {
        self.showCompletedTasks.toggle()
        loadData()
    }
    
    func bindTodoList(_ update: @escaping ([TodoItem]) -> Void) {
        $todoItems.bind(action: update)
    }
    
    func bindCompletedTodoListCount(_ update: @escaping (Int) -> Void) {
        $completedTasksCount.bind(action: update)
    }
}
