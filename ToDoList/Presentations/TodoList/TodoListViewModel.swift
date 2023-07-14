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
            
    private var database: DatabaseService
            
    // MARK: - Initialization
    init(database: DatabaseService) {
        self.database = database
        
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
        do {
            try database.addItem(item)
        } catch {
            print(error)
        }
        fetchTodoItems()
    }
    
    func updateItem(_ item: TodoItem) {
        do {
            try database.updateItem(item)
        } catch {
            print(error)
        }
        fetchTodoItems()
    }
    
    func deleteItem(_ item: TodoItem) {
        do {
            try database.deleteItem(item)
        } catch {
            print(error)
        }
        fetchTodoItems()
    }
    
    func fetchTodoItems() {
        do {
            try database.loadItems { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let items):
                    self.todoItems = items
                    self.completedTasksCount = todoItems.filter({ $0.isDone }).count
                case.failure(let error):
                    print(error)
                }
            }
        } catch {
            print(error)
        }
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
        database = service
    }
}
