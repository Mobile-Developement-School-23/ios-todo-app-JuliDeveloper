import Foundation

protocol DatabaseService {
    func addItem(_ item: TodoItem) throws
    func updateItem(_ item: TodoItem) throws
    func deleteItem(_ item: TodoItem) throws
    func loadItems(_ completion: (Result<[TodoItem], Error>) -> Void) throws
}

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
    private let database: DatabaseService
            
    // MARK: - Initialization
    init(
        fileCache: FileCacheSQLiteProtocol = FileCache(),
        database: DatabaseService = CoreDataService()
    ) {
        self.fileCache = fileCache
        self.database = database
        
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
        do {
            try database.addItem(item)
        } catch {
            print(error)
        }
        loadData()
    }
    
    func updateItem(_ item: TodoItem) {
        do {
            try database.updateItem(item)
        } catch {
            print(error)
        }
        loadData()
    }
    
    func deleteItem(_ item: TodoItem) {
        do {
            try database.deleteItem(item)
        } catch {
            print(error)
        }
        loadData()
    }
    
    func loadData() {
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
    
    func saveData() {
//        fileCache.saveToDb(items: todoItems)
//        loadData()
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
