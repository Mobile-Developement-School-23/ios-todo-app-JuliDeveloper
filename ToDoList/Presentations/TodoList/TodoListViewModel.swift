import Foundation

protocol TodoListViewModelProtocol {
    var todoList: [TodoItem] { get }
    var tasksToShow: [TodoItem] { get }
    var completedListCount: Int { get }
    func addItem(_ item: TodoItem)
    func updateItem(_ item: TodoItem)
    func deleteItem(_ item: TodoItem)
    func fetchTodoItems()
    func updateItemIsDone(from todoItem: TodoItem) -> TodoItem
    func toggleShowCompletedList()
    func bindTodoList(_ update: @escaping ([TodoItem]) -> Void)
    func bindCompletedTodoListCount(_ update: @escaping (Int) -> Void)
    func updateDatabaseService(service: DatabaseService)
}

final class TodoListViewModel: ObservableObject {
    
    // MARK: - Properties
    @Observable var todoItems: [TodoItem] = []
    @Observable var showCompletedTasks: Bool = false
    @Observable var completedTasksCount: Int = 0
            
    private var fileCache: FileCacheDatabaseProtocol
            
    // MARK: - Initialization
    init(fileCache: FileCacheDatabaseProtocol) {
        self.fileCache = fileCache
        
        fetchTodoItems()
    }
}

// MARK: - TodoListViewModelProtocol
extension TodoListViewModel: TodoListViewModelProtocol {
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
        fileCache.addItemDB(item)
        fetchTodoItems()
    }
    
    func updateItem(_ item: TodoItem) {
        fileCache.updateItemDB(item)
        fetchTodoItems()
    }
    
    func deleteItem(_ item: TodoItem) {
        fileCache.deleteItemDB(item)
        fetchTodoItems()
    }
    
    func fetchTodoItems() {
        fileCache.fetchTodoItemsDB()
        todoItems = fileCache.todoListDB
        completedTasksCount = todoItems.filter({ $0.isDone }).count
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
        fetchTodoItems()
    }
    
    func bindTodoList(_ update: @escaping ([TodoItem]) -> Void) {
        $todoItems.bind(action: update)
    }
    
    func bindCompletedTodoListCount(_ update: @escaping (Int) -> Void) {
        $completedTasksCount.bind(action: update)
    }
    
    func updateDatabaseService(service: DatabaseService) {
        fileCache.updateDatabaseService(service: service)
    }
}
